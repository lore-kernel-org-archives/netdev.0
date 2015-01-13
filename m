From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/6] vxlan: Group Policy extension
Date: Mon, 12 Jan 2015 18:28:50 -0800
Message-ID: <CA+mtBx8-rMYSkj2KKXBq60KeF=V=iCG2K0HgVxO5JMVK1yhwCg@mail.gmail.com>
References: <cover.1420756324.git.tgraf@suug.ch>
	<7339e3bff124cecaf65cd04ea9bdc973c730ba34.1420756324.git.tgraf@suug.ch>
	<CA+mtBx8SWiwjBfxx05omur1gDeF9QcKtjDKJQ+XdUgi_U8LWig@mail.gmail.com>
	<20150113010357.GB20387@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:43023 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752546AbbAMC2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 21:28:51 -0500
Received: by mail-ig0-f169.google.com with SMTP id z20so14388322igj.0
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 18:28:50 -0800 (PST)
In-Reply-To: <20150113010357.GB20387@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2015 at 5:03 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 01/12/15 at 10:14am, Tom Herbert wrote:
>> > diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>> > index f7d0d2d..9f07bf5 100644
>> > --- a/include/uapi/linux/if_link.h
>> > +++ b/include/uapi/linux/if_link.h
>> > @@ -370,10 +370,18 @@ enum {
>> >         IFLA_VXLAN_UDP_CSUM,
>> >         IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
>> >         IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
>> > +       IFLA_VXLAN_EXTENSION,
>> >         __IFLA_VXLAN_MAX
>> >  };
>> >  #define IFLA_VXLAN_MAX (__IFLA_VXLAN_MAX - 1)
>> >
>> > +enum {
>> > +       IFLA_VXLAN_EXT_UNSPEC,
>> > +       IFLA_VXLAN_EXT_GBP,
>> > +       __IFLA_VXLAN_EXT_MAX,
>> > +};
>> > +#define IFLA_VXLAN_EXT_MAX (__IFLA_VXLAN_EXT_MAX - 1)
>> > +
>>
>> Creating a level of indirection for extensions seems overly
>> complicated to me. Why not just define IFLA_VXLAN_GBP as just another
>> enum above?
>
> I think it's cleaner to group them in a nested attribute.
> It clearly separates the optional extensions from the base
> attributes. RCO, GPE, GBP can all live in there.

This is inconsistent with similar things in GRE and GUE. For instance,
GRE keyid is set as its own attribute. It just seems like this adding
more code to the driver than is necessary for the functionality
needed.
