From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] net/ipv6: add sysctl option accept_ra_hop_limit
Date: Fri, 24 Jul 2015 13:48:12 +0900
Message-ID: <55B1C38C.2000903@miraclelinux.com>
References: <1437709989-30041-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:32985 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbbGXEsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 00:48:16 -0400
Received: by pdbnt7 with SMTP id nt7so7460893pdb.0
        for <netdev@vger.kernel.org>; Thu, 23 Jul 2015 21:48:16 -0700 (PDT)
In-Reply-To: <1437709989-30041-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hangbin Liu wrote:
> Commit 6fd99094de2b ("ipv6: Don't reduce hop limit for an interface")
> disabled accept hop limit from RA if it is higher than the current hop
> limit for security stuff. But this behavior kind of break the RFC definition.
> 
> RFC 4861, 6.3.4.  Processing Received Router Advertisements
>    If the received Cur Hop Limit value is non-zero, the host SHOULD set
>    its CurHopLimit variable to the received value.
> 
> So add sysctl option accept_ra_hop_limit to let user choose whether accept
> hop limit info in RA.
> 
> Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  Documentation/networking/ip-sysctl.txt | 11 +++++++++++
>  include/linux/ipv6.h                   |  1 +
>  include/uapi/linux/ipv6.h              |  1 +
>  net/ipv6/addrconf.c                    | 10 ++++++++++
>  net/ipv6/ndisc.c                       | 17 +++++++++++------
>  5 files changed, 34 insertions(+), 6 deletions(-)
> 
:
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 5efa54a..9f40ac9 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -153,6 +153,7 @@ enum {
>  	DEVCONF_FORCE_MLD_VERSION,
>  	DEVCONF_ACCEPT_RA_DEFRTR,
>  	DEVCONF_ACCEPT_RA_PINFO,
> +	DEVCONF_ACCEPT_RA_HOP_LIMIT,
>  	DEVCONF_ACCEPT_RA_RTR_PREF,
>  	DEVCONF_RTR_PROBE_INTERVAL,
>  	DEVCONF_ACCEPT_RA_RT_INFO_MAX_PLEN,

No, you cannot add new one in the middle of these since 
values are exported to userspace.

--yoshfuji
