From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Tue, 13 Jan 2015 01:03:57 +0000
Message-ID: <20150113010357.GB20387@casper.infradead.org>
References: <cover.1420756324.git.tgraf@suug.ch>
 <7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
 <CA+mtBx8SWiwjBfxx05omur1gDeF9QcKtjDKJQ+XdUgi_U8LWig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:48677 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbbAMBD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 20:03:58 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx8SWiwjBfxx05omur1gDeF9QcKtjDKJQ+XdUgi_U8LWig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/15 at 10:14am, Tom Herbert wrote:
> > diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> > index f7d0d2d..9f07bf5 100644
> > --- a/include/uapi/linux/if_link.h
> > +++ b/include/uapi/linux/if_link.h
> > @@ -370,10 +370,18 @@ enum {
> >         IFLA_VXLAN_UDP_CSUM,
> >         IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
> >         IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
> > +       IFLA_VXLAN_EXTENSION,
> >         __IFLA_VXLAN_MAX
> >  };
> >  #define IFLA_VXLAN_MAX (__IFLA_VXLAN_MAX - 1)
> >
> > +enum {
> > +       IFLA_VXLAN_EXT_UNSPEC,
> > +       IFLA_VXLAN_EXT_GBP,
> > +       __IFLA_VXLAN_EXT_MAX,
> > +};
> > +#define IFLA_VXLAN_EXT_MAX (__IFLA_VXLAN_EXT_MAX - 1)
> > +
> 
> Creating a level of indirection for extensions seems overly
> complicated to me. Why not just define IFLA_VXLAN_GBP as just another
> enum above?

I think it's cleaner to group them in a nested attribute.
It clearly separates the optional extensions from the base
attributes. RCO, GPE, GBP can all live in there.
