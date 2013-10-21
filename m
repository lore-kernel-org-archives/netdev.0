From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] packet: Deliver VLAN TPID to userspace
Date: Mon, 21 Oct 2013 10:24:54 +0100
Message-ID: <1382347494.25689.8.camel@deadeye.wl.decadent.org.uk>
References: <87a9i6jymc.wl%atzm@stratosphere.co.jp>
	 <20131018105655.2cdc628e@nehalam.linuxnetplumber.net>
	 <87k3h9hjen.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31063 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab3JUJZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:25:19 -0400
In-Reply-To: <87k3h9hjen.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-10-19 at 15:19 +0900, Atzm Watanabe wrote:
> At Fri, 18 Oct 2013 10:56:55 -0700,
> Stephen Hemminger wrote:
> > 
> > On Sat, 19 Oct 2013 02:08:11 +0900
> > Atzm Watanabe <atzm@stratosphere.co.jp> wrote:
> > 
> > > diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> > > index dbf0666..6e36e0a 100644
> > > --- a/include/uapi/linux/if_packet.h
> > > +++ b/include/uapi/linux/if_packet.h
> > > @@ -83,7 +83,7 @@ struct tpacket_auxdata {
> > >  	__u16		tp_mac;
> > >  	__u16		tp_net;
> > >  	__u16		tp_vlan_tci;
> > > -	__u16		tp_padding;
> > > +	__u16		tp_vlan_tpid;
> > >  };
> > >  
> > >  /* Rx ring - header status */
> > > @@ -132,12 +132,13 @@ struct tpacket2_hdr {
> > >  	__u32		tp_sec;
> > >  	__u32		tp_nsec;
> > >  	__u16		tp_vlan_tci;
> > > -	__u16		tp_padding;
> > > +	__u16		tp_vlan_tpid;
> > >  };
> > >  
> > >  struct tpacket_hdr_variant1 {
> > >  	__u32	tp_rxhash;
> > >  	__u32	tp_vlan_tci;
> > > +	__u32	tp_vlan_tpid;
> > >  };
> > 
> > The last change will break ABI to userspace applications.
> > You can reuse padding elements; but you can't increase (or shrink)
> > an existing structure.
> 
> Thank you for pointing.
> But I have two questions:
> 
>   - The patch that increases existing structures was posted and
>     accepted in the past (e.g 393e52e33c6c26ec7db290dab803bac1bed962d4
>     "packet: deliver VLAN TCI to userspace").
>     What is the difference between them and my patch?

struct tpacket_auxdata is allowed to grow as it will be written/read
using the cmsg API where the length of each structure is explicit at
run-time.

>   - I tested using tools/testing/selftests/net/psock_tpacket.c built
>     before applying my patch, and all test cases were passed.
>     Also I tested by the code that was listed in
>     Documentation/networking/packet_mmap.txt "AF_PACKET TPACKET_V3
>     example".  It seems that problem was not caused.
>     What situation causes the problem that you assumed?

Yes, it looks like it would be safe to grow struct tpacket3_hdr too, as
the length is also explicit at run-time.

(And TPACKET{1,2,3}_HDRLEN should be removed from
include/uapi/linux/if_packet.h, as they are not relevant to userland.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
