From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: avoid passing negative numbers to malloc
Date: Tue, 12 Nov 2013 15:18:47 -0800
Message-ID: <1384298327.28458.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131112185214.GA29913@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:54115 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756722Ab3KLXSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 18:18:48 -0500
Received: by mail-pa0-f52.google.com with SMTP id kl14so1715865pab.25
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 15:18:48 -0800 (PST)
In-Reply-To: <20131112185214.GA29913@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-12 at 19:52 +0100, Andreas Henriksson wrote:
> Example:
> 
> $ ss state established \( sport = :4060  or sport = :4061 or sport = :4062  or sport = :4063 or sport = :4064  or sport = :4065 or sport = :4066  or sport = :4067 \)  > /dev/null
> Aborted
> 
> In the example above ssfilter_bytecompile(...) will return (int)136.
> char l1 = 136; means -120 which will result in a negative number
> being passed to malloc at misc/ss.c:913.
> 
> Simply declare l1 and l2 as intergers to avoid the char overflow.
> 
> This is one of the issues originally reported in http://bugs.debian.org/511720
> 
> Reported-by: Andreas Schuldei <andreas@debian.org>
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  misc/ss.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index c0369f1..db3a3a4 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -907,7 +907,8 @@ static int ssfilter_bytecompile(struct ssfilter *f, char **bytecode)
>  	}
>  		case SSF_OR:
>  	{
> -		char *a1, *a2, *a, l1, l2;
> +		char *a1, *a2, *a;
> +		int l1, l2;
>  		l1 = ssfilter_bytecompile(f->pred, &a1);
>  		l2 = ssfilter_bytecompile(f->post, &a2);
>  		if (!(a = malloc(l1+l2+4))) abort();

Please fix the other cases (SSF_NOT and SSF_AND) ?

Thanks !
