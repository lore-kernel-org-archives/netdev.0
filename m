From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: mask out FLOW_EXT
Date: Wed, 01 Jun 2011 21:02:29 +0100
Message-ID: <1306958549.2758.3.camel@bwh-desktop>
References: <31603.80.254.147.148.1306158835.squirrel@webmail.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sebastian.poehn@belden.com
To: s.poehn@stud.hs-esslingen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:40999 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab1FAUCd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 16:02:33 -0400
In-Reply-To: <31603.80.254.147.148.1306158835.squirrel@webmail.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-23 at 15:53 +0200, Sebastian P=C3=B6hn wrote:
> Sorry for the disclaimer the last time!
>=20
> The FLOW_EXT bit must be masked out. Otherwise if e.g. vlan is set a
> driver receiving the ntuple may not detect the flow_type correctly!
>=20
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
> ---
>=20
> diff --git a/ethtool.c b/ethtool.c
> index 34fe107..0b7ec05 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -3134,6 +3134,9 @@ static int flow_spec_to_ntuple(struct
> ethtool_rx_flow_spec *fsp,
>                  (u64)ntohl(~fsp->m_ext.data[1]);
>          }
>      }
> +
> +    /*Mask out the extended bit, because ntuple does not know it!*/
> +    ntuple->flow_type &=3D ~FLOW_EXT;
>=20
>      return 0;
>  }

Applied, with fixes to spacing.  Thanks.

In future, please ensure that your editor and mailer do *not* convert
tabs to spaces.  Also put spaces between the comment delimiters and
text, consistent with the rest of the code.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

