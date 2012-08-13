From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next 15/16] net: remove usage of dev->master
Date: Mon, 13 Aug 2012 19:31:41 +0200
Message-ID: <20120813173141.GB1808@minipsycho.orion>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
 <1344871635-1052-16-git-send-email-jiri@resnulli.us>
 <1344878131.2733.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
	divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org, therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org,
	gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1344878131.2733.28.camel-/LGg1Z1CJKReKY3V0RtoKmatzQS1i7+A3tAM5lWOD0I@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Mon, Aug 13, 2012 at 07:15:31PM CEST, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org wrote:
>On Mon, 2012-08-13 at 17:27 +0200, Jiri Pirko wrote:
>> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
>> ---
>>  net/core/dev.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index c0f9adb..8977404 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -5461,8 +5461,8 @@ static void rollback_registered_many(struct list_head *head)
>>  		if (dev->netdev_ops->ndo_uninit)
>>  			dev->netdev_ops->ndo_uninit(dev);
>>  
>> -		/* Notifier chain MUST detach us from master device. */
>> -		WARN_ON(dev->master);
>> +		/* Notifier chain MUST detach us all upper devices. */
>> +		WARN_ON(netdev_has_any_upper_dev(dev));
>>  
>>  		/* Remove entries from kobject tree */
>>  		netdev_unregister_kobject(dev);
>
>I think this should be folded into patch 1, since that already ensures
>that any master device is included in the upper device list.

Right, I will squash it into patch 1

>
>Ben.
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
