From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: linux-next: Tree for May 24 (ratelimits, CONFIG_PRINTK not enabled)
Date: Tue, 24 May 2011 13:11:51 -0700
Message-ID: <4DDC1107.4050004@oracle.com>
References: <1306262988.2298.49.camel@Joe-Laptop>	<20110524.153222.1953796640575918161.davem@davemloft.net>	<1306266580.2298.55.camel@Joe-Laptop> <20110524.155337.1293466135362760665.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110524.155337.1293466135362760665.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/24/11 12:53, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Tue, 24 May 2011 12:49:40 -0700
> 
>> On Tue, 2011-05-24 at 15:32 -0400, David Miller wrote:
>>> From: Joe Perches <joe@perches.com>
>>> Date: Tue, 24 May 2011 11:49:48 -0700
>>>> On Tue, 2011-05-24 at 11:33 -0700, Randy Dunlap wrote:
>>>>> Adding <linux/ratelimit.h> to <asm-generic/bug.h> causes other problems:
>>>> Yup, that's not a good solution.
>>> Please come up with a fix or I'll have to revert, thanks Joe.
>>
>> I have some errands to run for awhile.
>>
>> Probably a revert today and another patch set tomorrow
>> might be best.
>>
>> This seems to work and doesn't cause any extra state to be
>> instantiated when !CONFIG_PRINTK.  What do you think?
> 
> Seems fine, here it is as a patch.
> 
> Randy please test this, thanks:

Works here.

Acked-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks.

> diff --git a/include/asm-generic/bug.h b/include/asm-generic/bug.h
> index 12b250c..9178484 100644
> --- a/include/asm-generic/bug.h
> +++ b/include/asm-generic/bug.h
> @@ -162,6 +162,8 @@ extern void warn_slowpath_null(const char *file, const int line);
>  	unlikely(__ret_warn_once);				\
>  })
>  
> +#ifdef CONFIG_PRINTK
> +
>  #define WARN_ON_RATELIMIT(condition, state)			\
>  		WARN_ON((condition) && __ratelimit(state))
>  
> @@ -181,6 +183,25 @@ extern void warn_slowpath_null(const char *file, const int line);
>  	__WARN_RATELIMIT(condition, &_rs, format);		\
>  })
>  
> +#else
> +
> +#define WARN_ON_RATELIMIT(condition, state)			\
> +	WARN_ON(condition)
> +
> +#define __WARN_RATELIMIT(condition, state, format...)		\
> +({								\
> +	int rtn = WARN(condition, format);			\
> +	rtn;							\
> +})
> +
> +#define WARN_RATELIMIT(condition, format...)			\
> +({								\
> +	int rtn = WARN(condition, format);			\
> +	rtn;							\
> +})
> +
> +#endif
> +
>  /*
>   * WARN_ON_SMP() is for cases that the warning is either
>   * meaningless for !SMP or may even cause failures.


-- 
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***
