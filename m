From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] prevent the read ahead of /proc/slabinfo in ss - take
 3
Date: Tue, 10 Feb 2015 15:51:29 +0300
Message-ID: <54D9FED1.9030903@cogentembedded.com>
References: <1423547533-6727-1-git-send-email-brytonlee01@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com
To: Bryton Lee <brytonlee01@gmail.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:34385 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755700AbbBJMvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2015 07:51:32 -0500
Received: by labms9 with SMTP id ms9so20012110lab.1
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2015 04:51:31 -0800 (PST)
In-Reply-To: <1423547533-6727-1-git-send-email-brytonlee01@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/10/2015 8:52 AM, Bryton Lee wrote:

> prevent the read ahead of /proc/slabinfo in ss.

> Signed-off-by: Bryton Lee <brytonlee01@gmail.com>
> ---
>   misc/ss.c | 13 ++++++++++---
>   1 file changed, 10 insertions(+), 3 deletions(-)

> diff --git a/misc/ss.c b/misc/ss.c
> index 7fc0a99..74721b5 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
[...]
> @@ -655,6 +656,8 @@ static int get_slabstat(struct slabstat *s)
>   			break;
>   	}
>
> +    slabstat_valid = 1;

    This is indented incorrectly. Use one TAB please.

> +
>   	fclose(fp);
>   	return 0;
>   }
> @@ -2230,6 +2233,9 @@ static int tcp_show(struct filter *f, int socktype)
>   	 * it is able to give us some memory for snapshot.
>   	 */
>   	if (1) {
> +		if (!slabstat_valid)
> +			get_slabstat(&slabstat);
> +
>   		int guess = slabstat.socks+slabstat.tcp_syns;
>   		if (f->states&(1<<SS_TIME_WAIT))
>   			guess += slabstat.tcp_tws;
> @@ -3196,6 +3202,9 @@ static int print_summary(void)
>   	if (get_snmp_int("Tcp:", "CurrEstab", &sn.tcp_estab) < 0)
>   		perror("ss: get_snmpstat");
>
> +	if (!slabstat_valid)
> +		get_slabstat(&slabstat);
> +

    Can't you perform this check inside get_slabstat()?

[...]

WBR, Sergei
