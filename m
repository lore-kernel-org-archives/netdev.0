From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] ibm_newemac: Fix new MAL feature handling
Date: Fri, 17 Oct 2008 14:56:52 +0200
Message-ID: <200810171456.53599.arnd@arndb.de>
References: <20081015213337.a99a9595.akpm@linux-foundation.org> <1224133010.8157.543.camel@pasglop> <20081016143840.GA29805@yoda.jdub.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Josh Boyer <jwboyer@linux.vnet.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:61766 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752942AbYJQM5O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 08:57:14 -0400
In-Reply-To: <20081016143840.GA29805@yoda.jdub.homelinux.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 16 October 2008, Josh Boyer wrote:
> +#ifdef CONFIG_PPC_DCR_NATIVE
> =A0=A0=A0=A0=A0=A0=A0=A0if (mal_has_feature(mal, MAL_FTR_CLEAR_ICINTS=
TAT))
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0mtdcri(SDR0, DCRN_SDR=
_ICINTSTAT,
> =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0(mfdcri(SDR0, DCRN_SDR_ICINTSTAT) | ICINTSTA=
T_ICTX));
> +#endif
> =A0

So what if you have a mmio based DRC implementation and still want to u=
se
this feature?

I guess you really should use dcr_read/dcr_write here instead of mtdcr/=
mfdcr.

	Arnd <><
