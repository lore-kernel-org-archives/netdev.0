From: Max Krasnyansky <maxk@qualcomm.com>
Subject: Re: tun device - bug or feature? WAS(Re: IMQ / new Dummy device
	post.
Date: Mon, 10 May 2004 10:18:02 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1084209482.758.15.camel@localhost>
References: <wazza.87ad18jbdl.fsf@message.id>
	 <1082427350.1034.70.camel@jzny.localdomain>
	 <wazza.87fzayw1fy.fsf@message.id> <wazza.87fzaxmr6x.fsf@message.id>
	 <wazza.87hdvddqxq.fsf@message.id>
	 <1082639764.1059.81.camel@jzny.localdomain>
	 <87oepjx65r.87n053x65r@87llknx65r.message.id>
	 <1082719745.1057.27.camel@jzny.localdomain>
	 <1082816083.1054.32.camel@jzny.localdomain>
	 <1083007898.7788.276.camel@localhost>
	 <1084017322.1041.30.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, syrius.ml@no-log.org, Jeff Garzik <jgarzik@pobox.com>,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1084017322.1041.30.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-05-08 at 04:55, jamal wrote:
> Max, Dave, Jeff,
> 
> I get what was bothering me now - it took me a while to formulate it:
> 
> TUN_TUN_DEV dev->type is ARPHRD_PPP
> dev->type is really related to link layer header, perhaps at the low
> level if neighbor discovery works well then we have a link-headerless
> packet which gets manipulated with the correct header by some generic
> code. The combination of dev->type and dev->hard_header_len works
> together to achieve this.
> In the case of TUN_TUN_DEV, the header_len is 0 ;->
> To be of type ARPHRD_PPP, tun needs to have a header_len which is the
> size of the l2 ppp header.
> As an example, TUN_TAP_DEV is fine as type ARPHRD_ETHER and header_len
> of ETH_HLEN.
> 
> A lot of devices are abusing this system, tun is not the only one.
> 
> My suggestion is to change dev->type to ARPHRD_VOID for TUN_TUN_DEV or
> we introduce something like ARPHDR_NONE for devices with link layer
> headers of size 0.
> 
> thoughts?

I have no problem with that. I mean introducing new ARPHDR_ type.
ARPHDR_PPP was simply most appropriate for TUN that's why I picked it.
I vote for ARPHDR_NONE.

Thanks
Max
