From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: That's pretty much it for 3.5.0
Date: Tue, 17 Jul 2012 16:27:53 -0700
Message-ID: <5005F4F9.6010208@intel.com>
References: <5005D008.6060103@intel.com> <20120717.140241.1599386555723262095.davem@davemloft.net> <5005E390.7020706@intel.com> <20120717.151832.1306978935355646723.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mark.d.rustad-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20120717.151832.1306978935355646723.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 7/17/2012 3:18 PM, David Miller wrote:
> From: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Date: Tue, 17 Jul 2012 15:13:36 -0700
>
>> Perhaps the easiest way is to check net->count this should be zero
>> until setup_net is called.
>>
>> if (!atomic_read(&init_net.count))
>> 	return ret;
>>
>
> Won't work, setup_net() runs via a pure_initcall().
>

Why not must have missed something? cgroup_init() and
cgroup_early_init() both run before _initcall() routines are
called via kernel_init() so this will stop the update in
netprio from occurring.

And I don't see any race elsewhere for this.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
