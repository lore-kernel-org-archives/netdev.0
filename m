From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute2 PATCH] utils: fix hex digits parsing in
 hexstring_a2n()
Date: Tue, 14 Jun 2016 14:25:50 -0700
Message-ID: <20160614142550.12a8cf76@xeon-e3>
References: <80a1168c78944f39ab2b270df68ad9e5@HQ1WP-EXMB11.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Beniamino Galvani <bgalvani@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:58122 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbcFNVZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:25:39 -0400
In-Reply-To: <80a1168c78944f39ab2b270df68ad9e5@HQ1WP-EXMB11.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 14 Jun 2016 20:55:17 +0000
Beniamino Galvani <bgalvani@redhat.com> wrote:

> strtoul() only modifies errno on overflow, so if errno is not zero
> before calling the function its value is preserved and makes the
> function fail for valid inputs; initialize it.
> 
> Signed-off-by: Beniamino Galvani <bgalvani@redhat.com>
> ---
>  lib/utils.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/lib/utils.c b/lib/utils.c
> index 70e85b7..7dceeb5 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -924,6 +924,7 @@ __u8 *hexstring_a2n(const char *str, __u8 *buf, int blen, unsigned int *len)
>  
>  		strncpy(tmpstr, str, 2);
>  		tmpstr[2] = '\0';
> +		errno = 0;
>  		tmp = strtoul(tmpstr, &endptr, 16);
>  		if (errno != 0 || tmp > 0xFF || *endptr != '\0')
>  			return NULL;

Applied.
The code here is doing things in a manner much harder than necessary...
