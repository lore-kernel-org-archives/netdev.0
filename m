From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [patch net-next 2/2] devlink: fix trace format string
Date: Thu, 14 Jul 2016 10:07:38 -0700
Message-ID: <b94d448d-6009-e444-bd98-abdc848cfb00@infradead.org>
References: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
 <1468489049-6326-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arnd@arndb.de, linux-kernel@vger.kernel.org,
	idosch@mellanox.com, yotamg@mellanox.com, eladr@mellanox.com,
	nogahf@mellanox.com, ogerlitz@mellanox.com, ivecera@redhat.com,
	rostedt@goodmis.org, mingo@redhat.com, jolsa@kernel.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468489049-6326-2-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/16 02:37, Jiri Pirko wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> 
> Including devlink.h on ARM and probably other 32-bit architectures results in
> a harmless warning:
> 
> In file included from ../include/trace/define_trace.h:95:0,
>                  from ../include/trace/events/devlink.h:51,
>                  from ../net/core/devlink.c:30:
> include/trace/events/devlink.h: In function 'trace_raw_output_devlink_hwmsg':
> include/trace/events/devlink.h:42:12: error: format '%lu' expects argument of type 'long unsigned int', but argument 10 has type 'size_t {aka unsigned int}' [-Werror=format=]
> 
> The correct format string for 'size_t' is %zu, not %lu, this works on all
> architectures.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: e5224f0fe2ac ("devlink: add hardware messages tracing facility")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
>  include/trace/events/devlink.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
> index 77dce71..09f1df2 100644
> --- a/include/trace/events/devlink.h
> +++ b/include/trace/events/devlink.h
> @@ -39,7 +39,7 @@ TRACE_EVENT(devlink_hwmsg,
>  		__entry->len = len;
>  	),
>  
> -	TP_printk("bus_name=%s dev_name=%s driver_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%lu",
> +	TP_printk("bus_name=%s dev_name=%s driver_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%zu",
>  		  __get_str(bus_name), __get_str(dev_name),
>  		  __get_str(driver_name), __entry->incoming, __entry->type,
>  		  (int) __entry->len, __get_dynamic_array(buf), __entry->len)
> 


-- 
~Randy
