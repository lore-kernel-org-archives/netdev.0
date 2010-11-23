From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] iproute2: support xfrm upper protocol gre key
Date: Tue, 23 Nov 2010 18:44:44 +0200
Message-ID: <4CEBEF7C.2060806@iki.fi>
References: <1290524559-22086-1-git-send-email-timo.teras@iki.fi> <20101123082404.5b8ad019@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:51163 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753962Ab0KWQos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 11:44:48 -0500
Received: by ewy5 with SMTP id 5so2549068ewy.19
        for <netdev@vger.kernel.org>; Tue, 23 Nov 2010 08:44:47 -0800 (PST)
In-Reply-To: <20101123082404.5b8ad019@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/23/2010 06:24 PM, Stephen Hemminger wrote:
> On Tue, 23 Nov 2010 17:02:39 +0200
> Timo Ter=E4s <timo.teras@iki.fi> wrote:
>=20
>> +	case IPPROTO_GRE:
>> +		if (sel->sport_mask || sel->dport_mask) {
>> +			struct in_addr key;
>> +			key.s_addr =3D htonl((ntohs(sel->sport) << 16) + ntohs(sel->dpor=
t));
>> +			inet_ntop(AF_INET, &key, abuf, sizeof(abuf));
>> +			fprintf(fp, "key %s ", abuf);
>> +		}
>=20
> The GRE key is not really an IPv4 address. Why should the utilities
> use IPv4 address manipulation to format/scan it.  It makes more sense
> to me to just use u32 an do the necessary ntohl.

This is pretty much how iptunnel.c does it, so I copied the code. Would
you prefer to format it as single u32 number? Or use something else for
formatting it similar to IPv4?

In either case, we should change iptunnel.c to match ipxfrm.c. It'll be
easier if both parts handling the gre key treat it equivalently.

I think Cisco does indeed treat it as u32 number in the configurations.
So I'm okay updating this patch, and fixing iptunnel.c side too. We
might still want to keep the parsing of ipv4 format to keep backwards
compatibility.
