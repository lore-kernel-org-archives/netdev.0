From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] support for large number of network devices.
Date: Tue, 13 Jan 2004 23:18:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040113231825.700e534f.davem@redhat.com>
References: <20040113154610.38f5934c.shemminger@osdl.org>
	<40048BFD.4010303@candelatech.com>
	<20040113163828.64ec4743.shemminger@osdl.org>
	<4004A194.3030602@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <4004A194.3030602@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 13 Jan 2004 17:55:32 -0800
Ben Greear <greearb@candelatech.com> wrote:

> Stephen Hemminger wrote:
> > I have a patch for name hashing, but don't know if it's needed.
> > Even without it I can add 9 thousand bridge entries,
> > and each one takes longer to start the command than add the entry now. 
> 
> Check out the af_packet code.  At least some branches do a
> device lookup by name for each transmitted packet.  One
> method is:  packet_sendmsg_spkt
> 
> packet_sendmsg gets by index, which could also be hashed...
> 
> At one time ifconfig -a was almost un-usable with large numbers
> of devices, but I think it has been improved.  I haven't tried on
> large numbers of devices lately...

I found some other fast-path'ish cases of dev_get_by_name(), one of which
is atalk_rcv()'s handling of IP over DDP packets.

I didn't even search around for __dev_get() and dev_get_by_index() cases.
There are probably some more there.

Therefore, I think it's wise to just do this right from the start and use a hash.
Stephen can you test up and submit the netdev name hash patch you have?
