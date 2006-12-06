From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 06 Dec 2006 13:51:07 +0000
Message-ID: <1165413068.5253.223.camel@pmac.infradead.org>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
	 <1165148731.12649.51.camel@pmac.infradead.org>
	 <20061204091341.GM8693@postel.suug.ch>
	 <1165410114.5253.218.camel@pmac.infradead.org>
	 <20061206134308.GL9556@sunsite.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33110 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760599AbWLFNvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 08:51:16 -0500
To: Jakub Jelinek <jakub@redhat.com>
In-Reply-To: <20061206134308.GL9556@sunsite.mff.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-06 at 14:43 +0100, Jakub Jelinek wrote:
> 
> +/* 2.6.19 kernel headers helpfully removed some macros and
> +   moved lots of stuff into new headers, some of which aren't
> +   included by linux/rtnetlink.h.  */
> +
> +#ifndef IFA_MAX
> +struct ifaddrmsg
> +{
> +  uint8_t ifa_family;
> +  uint8_t ifa_prefixlen;
> +  uint8_t ifa_flags;
> +  uint8_t ifa_scope;
> +  uint32_t ifa_index;
> +};
> +
> +enum
> +{
> +  IFA_UNSPEC,
> +  IFA_ADDRESS,
> +  IFA_LOCAL,
> +  IFA_LABEL,
> +  IFA_BROADCAST,
> +  IFA_ANYCAST,
> +  IFA_CACHEINFO,
> +  IFA_MULTICAST
> +};
> +#endif
> +
> +#ifndef IFA_F_SECONDARY
> +# define IFA_F_SECONDARY       0x01
> +# define IFA_F_TEMPORARY       IFA_F_SECONDARY
> +# define IFA_F_HOMEADDRESS     0x10
> +# define IFA_F_DEPRECATED      0x20
> +#endif

This much is still available from the new <linux/if_addr.h> -- you could
include that directly instead of copying it.

-- 
dwmw2

