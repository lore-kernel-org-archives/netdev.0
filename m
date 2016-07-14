From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [patch net-next 1/2] tracing: change owner name to driver name
 for devlink hwmsg tracepoint
Date: Thu, 14 Jul 2016 10:07:33 -0700
Message-ID: <89c61610-47f0-bfab-0642-7152f90936e8@infradead.org>
References: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arnd@arndb.de, linux-kernel@vger.kernel.org,
	idosch@mellanox.com, yotamg@mellanox.com, eladr@mellanox.com,
	nogahf@mellanox.com, ogerlitz@mellanox.com, ivecera@redhat.com,
	rostedt@goodmis.org, mingo@redhat.com, jolsa@kernel.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468489049-6326-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/14/16 02:37, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Turned on that driver->owner which is struct module is not available when
> modules are disabled. Better to depend on a driver name which is
> always available.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Fixes: e5224f0fe2 ("devlink: add hardware messages tracing facility")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Acked-by: Randy Dunlap <rdunlap@infradead.org>

Thanks.

> ---
>  include/trace/events/devlink.h | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/include/trace/events/devlink.h b/include/trace/events/devlink.h
> index 333c32a..77dce71 100644
> --- a/include/trace/events/devlink.h
> +++ b/include/trace/events/devlink.h
> @@ -22,7 +22,7 @@ TRACE_EVENT(devlink_hwmsg,
>  	TP_STRUCT__entry(
>  		__string(bus_name, devlink->dev->bus->name)
>  		__string(dev_name, dev_name(devlink->dev))
> -		__string(owner_name, devlink->dev->driver->owner->name)
> +		__string(driver_name, devlink->dev->driver->name)
>  		__field(bool, incoming)
>  		__field(unsigned long, type)
>  		__dynamic_array(u8, buf, len)
> @@ -32,16 +32,16 @@ TRACE_EVENT(devlink_hwmsg,
>  	TP_fast_assign(
>  		__assign_str(bus_name, devlink->dev->bus->name);
>  		__assign_str(dev_name, dev_name(devlink->dev));
> -		__assign_str(owner_name, devlink->dev->driver->owner->name);
> +		__assign_str(driver_name, devlink->dev->driver->name);
>  		__entry->incoming = incoming;
>  		__entry->type = type;
>  		memcpy(__get_dynamic_array(buf), buf, len);
>  		__entry->len = len;
>  	),
>  
> -	TP_printk("bus_name=%s dev_name=%s owner_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%lu",
> +	TP_printk("bus_name=%s dev_name=%s driver_name=%s incoming=%d type=%lu buf=0x[%*phD] len=%lu",
>  		  __get_str(bus_name), __get_str(dev_name),
> -		  __get_str(owner_name), __entry->incoming, __entry->type,
> +		  __get_str(driver_name), __entry->incoming, __entry->type,
>  		  (int) __entry->len, __get_dynamic_array(buf), __entry->len)
>  );
>  
> 


-- 
~Randy
