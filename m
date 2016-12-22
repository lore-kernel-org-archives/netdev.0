From: Arend Van Spriel <arend.vanspriel@broadcom.com>
Subject: Re: [PATCH 2/2] net: wireless: fix to uses struct
Date: Thu, 22 Dec 2016 10:37:01 +0100
Message-ID: <eb612d84-a626-8bc1-bd7e-0c427489793e@broadcom.com>
References: <608881482358981@web17g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: Ozgur Karatas <okaratas@member.fsf.org>,
        johannes <johannes@sipsolutions.net>,
        David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <608881482358981@web17g.yandex.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 21-12-2016 23:23, Ozgur Karatas wrote:
> 
> The patch fixed to struct uses in reg.c, I think doesn't need to be use to "struct". 
> There is dataype not have to logical link and each is different definitons.
> 
> I'm undecided on this patch. I compiled and didn't to errors.

There must be something wrong in the way you build stuff, but still just
looking at your patch it is fundamentally wrong, which is what makes
people say "do a basic C course". Let me try and explain below.

> Signed-off-by: Ozgur Karatas <okaratas@member.fsf.org>
> ---
>  net/wireless/reg.c  | 10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/net/wireless/reg.c b/net/wireless/reg.c
> index 5dbac37..5b70970 100644
> --- a/net/wireless/reg.c
> +++ b/net/wireless/reg.c
> @@ -490,7 +490,7 @@ static int reg_query_builtin(const char *alpha2)
>  	if (!regdom)
>  		return -ENODATA;
>  
> -	request = kzalloc(sizeof(struct reg_regdb_apply_request), GFP_KERNEL);
> +	request = kzalloc(sizeof(*reg_regdb_apply_request), GFP_KERNEL);

Making it more abstract to explain what you are doing:

x = foo(sizeof(T), GFP_KERNEL); where T is "struct Y".

which you change to:

x = foo(sizeof(*Y), GFP_KERNEL);

Y has no meaning for the sizeof operator and the compiler will yell at
it being an unknown identifier. In a lot of kernel code you will find:

x = foo(sizeof(*x), GFP_KERNEL);

which is probably the coding style fix you are attempting to make, but
miserably fail to do so. There is nothing linux kernel specific about
this. It is really fundamental knowledge of the C language. The correct
change for this instance is:

-	request = kzalloc(sizeof(struct reg_regdb_apply_request), GFP_KERNEL);
+	request = kzalloc(sizeof(*request), GFP_KERNEL);

Hope this helps to come up with a working V2 of this patch.

Regards,
Arend
