From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 18:22:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.182234.74725315.davem@redhat.com>
References: <3EE67D2D.80608@candelatech.com>
	<20030610.180120.71112140.davem@redhat.com>
	<3EE682B8.8060708@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3EE682B8.8060708@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Tue, 10 Jun 2003 18:15:36 -0700
   
   What determines whether or not we use the "TSC do_gettimeofday".  Does
   it automagically happen when you compile for P-III or something like
   that?
   
The 2.5.x kernel has x86 platform  drivers that decide this.

   And how big of a "bigger box" are you talking about...regular old
   SMP, or NUMA?

Many laptops cannot even use TSC reliably because of power management
etc. issues.

   > SO_RECVSTAMP, any socket on the machine can ask for this.
   
   Do we know when we are being asked for this value?

We have to take the timestamp at netif_receive_skb() for it to
be accurate.

We don't even know if this packet is for this host until a long
time later, let alone whether any local sockets want SO_RECVSTAMP
or whether any IP options want timestamp or whether tcpdump is
listening etc.
