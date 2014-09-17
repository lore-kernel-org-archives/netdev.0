From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip lib: Change timestamp to be shorter and on
 the same line
Date: Tue, 16 Sep 2014 19:38:50 -0700
Message-ID: <20140916193850.4dec41e8@urahara>
References: <1410861486-2631-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:40698 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbaIQCi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 22:38:59 -0400
Received: by mail-pd0-f178.google.com with SMTP id p10so1073846pdj.37
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 19:38:58 -0700 (PDT)
In-Reply-To: <1410861486-2631-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2014 12:58:06 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> Changed timestamp format to look like more logging info:
> 
> [Sep 01 20:56:11.853146]2: enp0s25: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default
>     link/ether 3c:97:0e:a3:86:2e brd ff:ff:ff:ff:ff:ff
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  lib/utils.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/lib/utils.c b/lib/utils.c
> index dc21567..03092ba 100644
> --- a/lib/utils.c
> +++ b/lib/utils.c
> @@ -772,14 +772,13 @@ __u8* hexstring_a2n(const char *str, __u8 *buf, int blen)
>  int print_timestamp(FILE *fp)
>  {
>  	struct timeval tv;
> -	char *tstr;
> +	char tstr[40] = {};
>  
>  	memset(&tv, 0, sizeof(tv));
>  	gettimeofday(&tv, NULL);
>  
> -	tstr = asctime(localtime(&tv.tv_sec));
> -	tstr[strlen(tstr)-1] = 0;
> -	fprintf(fp, "Timestamp: %s %ld usec\n", tstr, (long)tv.tv_usec);
> +	strftime(tstr, sizeof(tstr), "%b %d %H:%M:%S", localtime(&tv.tv_sec));
> +	fprintf(fp, "[%s.%ld]", tstr, (long)tv.tv_usec);
>  	return 0;
>  }
>  

I am loath to change the output format since people write scripts parsing
output. Maybe add a new flag option to choose format?
