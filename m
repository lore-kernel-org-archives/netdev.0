From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
Subject: Re: [PATCH] iproute2: Avoid rounding errors for 100%.
Date: Tue, 03 Nov 2009 17:19:45 +0100
Message-ID: <4AF05821.60303@nets.rwth-aachen.de>
References: <1257262694-16985-1-git-send-email-hannemann@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Arnd Hannemann <Arnd.Hannemann@nets.rwth-aachen.de>
To: "shemminger@osdl.org" <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:49619 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751650AbZKCQUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 11:20:01 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KSJ00DCXK1IE550@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 03 Nov 2009 17:20:06 +0100 (CET)
In-reply-to: <1257262694-16985-1-git-send-email-hannemann@nets.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Although the patch makes sense,
it does not fix the bug/effect we were seeing.
A netem reorder percentage of 100% will still get packets reordered.
(if the netem queue is not empty)


hannemann@nets.rwth-aachen.de wrote:
> From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> 
> We noticed that a netem reorder percentage of 100% will still get packets reordered.
> This patch fixes that.
> 
> Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
> ---
>  tc/tc_util.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/tc/tc_util.c b/tc/tc_util.c
> index fe2c7eb..2641f2e 100644
> --- a/tc/tc_util.c
> +++ b/tc/tc_util.c
> @@ -363,8 +363,10 @@ int get_percent(__u32 *percent, const char *str)
>  		return -1;
>  	if (*p && strcmp(p, "%"))
>  		return -1;
> -
> -	*percent = (unsigned) rint(per * max_percent_value);
> +	if (per == 1.)
> +		*percent = max_percent_value;
> +	else
> +		*percent = (unsigned) rint(per * max_percent_value);
>  	return 0;
>  }
>  


-- 
Dipl.-Inform. Arnd Hannemann
RWTH Aachen University
Dept. of Computer Science, Informatik 4
Ahornstr. 55, D-52074 Aachen, Germany
Phone: (+49 241) 80-21423 Fax: (+49 241) 80-22220
