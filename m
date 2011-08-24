From: "Yan, Zheng " <yanzheng@21cn.com>
Subject: Re: [PATCH] mcast: Fix source address selection for multicast
 listener report.
Date: Wed, 24 Aug 2011 16:47:14 +0800
Message-ID: <CAAM7YAmdYmzgR0fax0J5MiVMPWtfs3toLG+G5z-ApTJXX5Oi1A@mail.gmail.com>
References: <CAAM7YAku7DgV_c7joAHCx5fP8Dea3Y_VaxbokdTR3m2ADz1qhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dlstevens@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:33866 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756459Ab1HXIrO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 04:47:14 -0400
Received: by pzk37 with SMTP id 37so473966pzk.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2011 01:47:14 -0700 (PDT)
In-Reply-To: <CAAM7YAku7DgV_c7joAHCx5fP8Dea3Y_VaxbokdTR3m2ADz1qhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2011 at 3:55 PM, Yan, Zheng <yanzheng@21cn.com> wrote:
> Should check use count of include mode filter instead of total number
> of include mode filters.
>
> Signed-off-by: Zheng Yan =A0<zheng.z.yan@intel.com>
> ---
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 283c0a2..d577199 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -767,7 +767,7 @@ static int igmp_xmarksources(struct ip_mc_list
> *pmc, int nsrcs, __be32 *srcs)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i=3D0; i<nsrcs; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* skip inactive filte=
rs */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pmc->sfcount[MCAST_=
INCLUDE] ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (psf->sf_count[MCAST=
_INCLUDE] ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pmc->sfcount[M=
CAST_EXCLUDE] !=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0psf->sf_count[=
MCAST_EXCLUDE])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
> diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
> index 3e6ebcd..ee7839f 100644
> --- a/net/ipv6/mcast.c
> +++ b/net/ipv6/mcast.c
> @@ -1059,7 +1059,7 @@ static int mld_xmarksources(struct ifmcaddr6
> *pmc, int nsrcs,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (i=3D0; i<nsrcs; i++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* skip inactive filte=
rs */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pmc->mca_sfcount[MC=
AST_INCLUDE] ||
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (psf->sf_count[MCAST=
_INCLUDE] ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pmc->mca_sfcou=
nt[MCAST_EXCLUDE] !=3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0psf->sf_count[=
MCAST_EXCLUDE])
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0contin=
ue;
>

Sorry. this one is malformed, please ignore it.
