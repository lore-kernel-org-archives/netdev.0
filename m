From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] ip link: Remove unnecessary device checking
Date: Sat, 30 Aug 2014 19:01:11 +0200
Message-ID: <54020357.2030301@hartkopp.net>
References: <1409400360-31612-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Mehdi Abaakouk <sileht@sileht.net>
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:38126 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbaH3RBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Aug 2014 13:01:14 -0400
In-Reply-To: <1409400360-31612-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.08.2014 14:06, Vadim Kochan wrote:
> The real checking is performed later in iplink_modify(..) func which
> checks device existence if NLM_F_CREATE flag is set.
> 
> Also it fixes the case when impossible to add veth link which was
> caused by 9a02651a87 (ip: check for missing dev arg when doing VF rate)
> because these devices are not exist yet.
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

This also fixes this issue from Mehdi Abaakouk here:
http://marc.info/?l=linux-netdev&m=140912053421637

And the stuff I needed to change here:
https://gitorious.org/linux-can/can-tests/commit/578d07b0a13e0c171801cde8c048ac657373491e

Thanks for figuring out the detailed problem Vadim!

Regards,
Oliver

> ---
>  ip/iplink.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index 1a907d9..ea06871 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -593,8 +593,6 @@ int iplink_parse(int argc, char **argv, struct iplink_req *req,
>  				duparg2("dev", *argv);
>  			*dev = *argv;
>  			dev_index = ll_name_to_index(*dev);
> -			if (dev_index == 0)
> -				invarg("Unknown device", *argv);
>  		}
>  		argc--; argv++;
>  	}
> 
