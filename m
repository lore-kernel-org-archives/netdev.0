From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH iproute2 REGRESSION] ss: Dont show netlink and packet
 sockets by default
Date: Sun, 14 Dec 2014 17:26:45 +0300
Message-ID: <548D9E25.30100@cogentembedded.com>
References: <1418549765-9466-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f173.google.com ([209.85.217.173]:38181 "EHLO
	mail-lb0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbaLNO0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 09:26:48 -0500
Received: by mail-lb0-f173.google.com with SMTP id z12so7853051lbi.4
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 06:26:45 -0800 (PST)
In-Reply-To: <1418549765-9466-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/14/2014 12:36 PM, Vadim Kochan wrote:

> From: Vadim Kochan <vadim4j@gmail.com>

> Checking by SS_CLOSE state was remowed in:

>      (45a4770bc0) ss: Remove checking SS_CLOSE state for packet and netlink

> which is not really correct because now by default all sockets are seen
> when do 'ss'.

> Here is most correct fix which considers specified family.

> To see netlink sockets:
>      ss -A netlink

> To see packet sockets:
>      ss -A packet

> And ss by default will show only connected/established sockets as it
> was before all the time.
>
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>   misc/ss.c | 6 ++++++
>   1 file changed, 6 insertions(+)

> diff --git a/misc/ss.c b/misc/ss.c
> index e9927a5..6050ab6 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -2801,6 +2801,9 @@ static int packet_show(struct filter *f)
>   	int ino;
>   	unsigned long long sk;
>
> +	if (preferred_family != AF_PACKET && !(f->states & (1<<SS_CLOSE)))

   Please surround << with spaces, to be consistent with other operators and 
general kernel coding style.

> +		return 0;
> +
>   	if (packet_show_netlink(f, NULL) == 0)
>   		return 0;
>
> @@ -3028,6 +3031,9 @@ static int netlink_show(struct filter *f)
>   	int rq, wq, rc;
>   	unsigned long long sk, cb;
>
> +	if (preferred_family != AF_NETLINK && !(f->states & (1<<SS_CLOSE)))

    Likewise.

> +		return 0;
> +
[...]

WBR, Sergei
