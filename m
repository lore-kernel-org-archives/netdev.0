From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH -next] netdev: inet_timewait_sock.h missing semi-colon
 when KMEMCHECK is enabled
Date: Mon, 14 Oct 2013 13:47:31 -0700
Message-ID: <525C5863.1000505@infradead.org>
References: <1381762088-18880-1-git-send-email-treding@nvidia.com>	 <525C47C0.2000907@infradead.org> <1381780437.12919.3.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thierry Reding <thierry.reding@gmail.com>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381780437.12919.3.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/14/13 12:53, Joe Perches wrote:
> On Mon, 2013-10-14 at 12:36 -0700, Randy Dunlap wrote:
>> From: Randy Dunlap <rdunlap@infradead.org>
>>
>> Fix (a few hundred) build errors due to missing semi-colon when
>> KMEMCHECK is enabled:
>>
>>   include/net/inet_timewait_sock.h:139:2: error: expected ',', ';' or '}' before 'int'
>>   include/net/inet_timewait_sock.h:148:28: error: 'const struct inet_timewait_sock' has no member named 'tw_death_node'
>>
>> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
>> ---
>>  include/net/inet_timewait_sock.h |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> --- next-2013-1014.orig/include/net/inet_timewait_sock.h
>> +++ next-2013-1014/include/net/inet_timewait_sock.h
>> @@ -135,7 +135,7 @@ struct inet_timewait_sock {
>>  				tw_transparent  : 1,
>>  				tw_pad		: 6,	/* 6 bits hole */
>>  				tw_tos		: 8,
>> -				tw_pad2		: 16 /* 16 bits hole */
>> +				tw_pad2		: 16;	/* 16 bits hole */
>>  	kmemcheck_bitfield_end(flags);
>>  	u32			tw_ttd;
>>  	struct inet_bind_bucket	*tw_tb;
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> 
> Shouldn't this be done in kmemcheck.h?

This patch makes sense and probably should be merged
but it does not fix the build errors that I reported.


>  include/linux/kmemcheck.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/kmemcheck.h b/include/linux/kmemcheck.h
> index 39f8453..b9ffad5 100644
> --- a/include/linux/kmemcheck.h
> +++ b/include/linux/kmemcheck.h
> @@ -62,10 +62,10 @@ bool kmemcheck_is_obj_initialized(unsigned long addr, size_t size);
>   *     kmemcheck_annotate_bitfield(a, flags);
>   */
>  #define kmemcheck_bitfield_begin(name)	\
> -	int name##_begin[0];
> +	int name##_begin[0]
>  
>  #define kmemcheck_bitfield_end(name)	\
> -	int name##_end[0];
> +	int name##_end[0]
>  
>  #define kmemcheck_annotate_bitfield(ptr, name)				\
>  	do {								\
> 
> 
> --



-- 
~Randy
