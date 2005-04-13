From: Neil Horman <nhorman@redhat.com>
Subject: Re: Ethernet bridge and PF_PACKET sockets
Date: Wed, 13 Apr 2005 08:35:12 -0400
Message-ID: <20050413123512.GA29996@hmsendeavour.rdu.redhat.com>
References: <3D81D46E0E63304FBC9ECEB136B4CF2610A1E8@BLR-EC-MBX04.wipro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: arun.prabha@wipro.com
Content-Disposition: inline
In-Reply-To: <3D81D46E0E63304FBC9ECEB136B4CF2610A1E8@BLR-EC-MBX04.wipro.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Apr 13, 2005 at 05:29:26PM +0530, arun.prabha@wipro.com wrote:
> Hi,
> 
> I am using a PF_PACKET socket to capture packets of a particular type,
> say ETH_P_X (where ETH_P_X is not ETH_P_ALL) from the ethernet
> interface, eth0. Everything will work fine. But when I configure a
> bridge br0, I feel that I will stop receiving the packets (since
> skb->dev is changed in br_pass_frame_up()).
> 
> 1. Is my reasoning incorrect?
More or less, I think, since bridge handling is done prior to the execution of
the registered packet_type function that PF_PACKET sockets register to recieve
frames in netif_receive_skb.  It looks to me as though any frame which the
bridge code decides belongs to it will be hidden from any packet socket attached
to a physical interface that is a member of a bridge. I'd test that theory out
just to be sure, but thats what the code looks like to me.

> 2. Is this the expected behavior?
It would appear that is expected/correct behavior.

> 3. What can I do to get the packets, bind to br0??
Yes, when a packet is claimed by the bridge, it is re-injected into the bottom
of the network stack at netif_rx.  This will give your PF_PACKET socket another
chance to receive the frame.  So if you bind it to the bridge interface, you
should see it.

> 4. Assuming bridge may/may not be always  configured and I want to get
>    packets from the ethernet interface (without really bothering about
>    the bridge), what is the best way to do it?
> 
I'm not 100% sure, but my guess would be to use an iptables module to intercept
the appropriate frames.

> I should be able to transmit packets on the ethernet via the PF_PACKET
> socket.
> 
Yes.

HTH
Neil

> Thanks in advance,
> Arun.
> 
> 

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/
