From: Rui Xiang <leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RFC 3/5] printk: modify printk interface for
	syslog_namespace
Date: Wed, 21 Nov 2012 17:41:58 +0800
Message-ID: <50ACA1E6.2040404@gmail.com>
References: <50A9EAF0.4000902@gmail.com>
	<20121119142926.GB4453@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20121119142926.GB4453-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

On 2012-11-19 22:29, Serge E. Hallyn wrote:> Quoting Rui Xiang (leo.ruixiang-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org):
>> From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>>
>> We re-implement printk by additional syslog_ns.
>>
>> The function include printk, /dev/kmsg, do_syslog and kmsg_dump should be modifyed
>> for syslog_ns. Previous identifier *** such as log_first_seq should be replaced
>> by syslog_ns->***.
>>
>> Signed-off-by: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Xiang Rui <rui.xiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> ---

.......

>>  	lockdep_on();
>> @@ -1624,7 +1618,8 @@ EXPORT_SYMBOL(vprintk_emit);
>>
>>  asmlinkage int vprintk(const char *fmt, va_list args)
>>  {
>> -	return vprintk_emit(0, -1, NULL, 0, fmt, args);
>> +	return vprintk_emit(0, -1, NULL, 0, fmt, args,
>> +				current_syslog_ns());
>>  }
>>  EXPORT_SYMBOL(vprintk);
>>
>> @@ -1636,7 +1631,8 @@ asmlinkage int printk_emit(int facility, int level,
>>  	int r;
>>
>>  	va_start(args, fmt);
>> -	r = vprintk_emit(facility, level, dict, dictlen, fmt, args);
>> +	r = vprintk_emit(facility, level, dict, dictlen, fmt, args,
>> +						current_syslog_ns());
>>  	va_end(args);
>>
>>  	return r;
>> @@ -1678,7 +1674,7 @@ asmlinkage int printk(const char *fmt, ...)
>>  	}
>>  #endif
>>  	va_start(args, fmt);
>> -	r = vprintk_emit(0, -1, NULL, 0, fmt, args);
>> +	r = vprintk_emit(0, -1, NULL, 0, fmt, args, current_syslog_ns());
>
> Current is meaningless here.  The default should be using init_syslog_ns.

Thank for your attention.

I understand what you mean.
printk -> init_syslog_log
nsprintk(ns) -> container syslog

I think it makes sense.

thanks
Libo Chen
