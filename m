From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch iproute2] iproute2: ipa: show switch id
Date: Wed, 08 Jul 2015 15:29:42 -0600
Message-ID: <559D9646.8090203@gmail.com>
References: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:34988 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759025AbbGHV3o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 17:29:44 -0400
Received: by iecuq6 with SMTP id uq6so164631620iec.2
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 14:29:44 -0700 (PDT)
In-Reply-To: <1436368098-21358-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/8/15 9:08 AM, Jiri Pirko wrote:
> We forgot to include this patch somehow. So do it now.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   ip/ipaddress.c | 8 ++++++++
>   1 file changed, 8 insertions(+)
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 85a81ba..b7b4e3e 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -688,6 +688,14 @@ int print_linkinfo(const struct sockaddr_nl *who,
>   				      b1, sizeof(b1)));
>   	}
>
> +	if (tb[IFLA_PHYS_SWITCH_ID]) {
> +		SPRINT_BUF(b1);
> +		fprintf(fp, "switchid %s ",
> +			hexstring_n2a(RTA_DATA(tb[IFLA_PHYS_SWITCH_ID]),
> +				      RTA_PAYLOAD(tb[IFLA_PHYS_SWITCH_ID]),
> +				      b1, sizeof(b1)));
> +	}
> +
>   	if (tb[IFLA_OPERSTATE])
>   		print_operstate(fp, rta_getattr_u8(tb[IFLA_OPERSTATE]));
>
>

Do Stephen's comments about port-name apply here?
    http://www.spinics.net/lists/netdev/msg322693.html

I was wondering if this should go into -details output rather than the 
default.
