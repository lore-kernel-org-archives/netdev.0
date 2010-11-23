From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: support xfrm upper protocol gre key
Date: Tue, 23 Nov 2010 08:24:04 -0800
Message-ID: <20101123082404.5b8ad019@nehalam>
References: <1290524559-22086-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?ISO-8859-1?B?VGVy5HM=?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56531 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962Ab0KWQY2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 11:24:28 -0500
In-Reply-To: <1290524559-22086-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Nov 2010 17:02:39 +0200
Timo Ter=E4s <timo.teras@iki.fi> wrote:

> +	case IPPROTO_GRE:
> +		if (sel->sport_mask || sel->dport_mask) {
> +			struct in_addr key;
> +			key.s_addr =3D htonl((ntohs(sel->sport) << 16) + ntohs(sel->dport=
));
> +			inet_ntop(AF_INET, &key, abuf, sizeof(abuf));
> +			fprintf(fp, "key %s ", abuf);
> +		}

The GRE key is not really an IPv4 address. Why should the utilities
use IPv4 address manipulation to format/scan it.  It makes more sense
to me to just use u32 an do the necessary ntohl.


--=20
