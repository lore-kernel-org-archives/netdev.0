From: Ben Greear <greearb@candelatech.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 18:51:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EE68B15.60802@candelatech.com>
References: <3EE67D2D.80608@candelatech.com>	<20030610.180120.71112140.davem@redhat.com>	<3EE682B8.8060708@candelatech.com> <20030610.182234.74725315.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030610.182234.74725315.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

>    Do we know when we are being asked for this value?
> 
> We have to take the timestamp at netif_receive_skb() for it to
> be accurate.
> 
> We don't even know if this packet is for this host until a long
> time later, let alone whether any local sockets want SO_RECVSTAMP
> or whether any IP options want timestamp or whether tcpdump is
> listening etc.

Yes, I understand why we want a time-stamp very early...but if
we can get _some_ sort of time stamp very cheap (TSC, for example)
then we can potentially defer the more expensive conversion of
this stamp into the equivalent of whatever do_gettimeofday will
give us.

We could set an 'is-timestamp-converted-already' flag on the skb and have
a macro that gets the timestamp.  This macro can do the conversion
as needed and return the value to calling code.  For platforms that do
not support TSC or it's equivalent, can just use gettimeofday for the
original stamp and set the flag..


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
