From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: ath9k crashing the kernel
Date: Tue, 26 Oct 2010 14:28:56 +0200
Message-ID: <4CC6C988.4070706@openwrt.org>
References: <AANLkTim=jD-C4DwDS2=KuQnhPOyP+Cnd-hUTdaZ7Opth@mail.gmail.com> <AANLkTikHTgoJyxm80MuXM9oTvCPTFAPM12zVih1RsTfy@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	shafi.wireless-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Jaswinder Singh <jaswinderlinux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTikHTgoJyxm80MuXM9oTvCPTFAPM12zVih1RsTfy-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2010-10-26 9:09 AM, Jaswinder Singh wrote:
>> ath9k is crashing the kernel :
>>
>> [   21.276554] BUG: spinlock bad magic on CPU#1, NetworkManager/1056
>> [   21.277015]  lock: f5be80a8, .magic: 00000000, .owner: <none>/-1,
>> .owner_cpu: 0
>> [   21.277015] Pid: 1056, comm: NetworkManager Not tainted 2.6.36-netbook+ #20
>> [   21.277015] Call Trace:
>> [   21.277015]  [<c14767a7>] ? printk+0xf/0x11
>> [   21.277015]  [<c117b823>] spin_bug+0x7c/0x87
>> [   21.301365]  [<c117b8bd>] do_raw_spin_lock+0x1e/0x125
>> [   21.301365]  [<c1478d0a>] ? _raw_spin_unlock_bh+0x1a/0x1c
>> [   21.301365]  [<c1478dc3>] _raw_spin_lock_irqsave+0x17/0x1c
>> [   21.318857]  [<c1288a74>] ath9k_config+0x255/0x38b
>> [   21.318857]  [<c1447bdb>] ieee80211_hw_config+0x10a/0x114
>> [...]
>>
>> Linux 2.6.36 f6f94e2ab1 is good
>> and
>> 229aebb873e2972 is bad
>>
> 
> After further investigation bad commit is :
> 
> 3430098ae463e31ab16926ac3eb295368a3ca5d9 is the first bad commit
> commit 3430098ae463e31ab16926ac3eb295368a3ca5d9
> Author: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
> Date:   Sun Oct 10 18:21:52 2010 +0200
> 
>     ath9k: implement channel utilization stats for survey
> 

This should already be fixed in wireless-testing by the following commit

commit 20b25744d1366762c6878d3254f93973cafe1f8e
Author: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Date:   Fri Oct 15 15:04:09 2010 -0700

    ath9k: Properly initialize ath_common->cc_lock.


- Felix
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
