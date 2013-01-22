From: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Mon, 21 Jan 2013 21:57:43 -0800
Message-ID: <50FE2A57.3040804@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com> <1358829606.3464.3151.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1358829606.3464.3151.camel@edumazet-glaptop>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/21/2013 08:40 PM, Eric Dumazet wrote:
> On Mon, 2013-01-21 at 16:32 -0800, Ben Greear wrote:
>> On 01/21/2013 01:07 PM, Ben Greear wrote:
>>> I posted about this a few days ago, but this time the patches applied
>>> are minimal and there are no out-of-tree kernel modules loaded.
>>
>> Here's another crash, this time with SLUB memory debugging turned on.
>>
>> Seems much harder to hit this way...I've only managed this one.  I
>> believe the RCX register might be interesting...that 6b is probably
>> freed memory poisioning.  Maybe skb or skb_dest() is already freed?
>>
>> I have added a 'verify_mem_not_deleted(skb)' before the
>> dst_input line in ip_rcv_finish..but so far, it hasn't
>> hit the problem...
>>
>
> There is no way skb is freed here.
>
> I would say macvlan is at fault here.
>
> It probably lacks a proper (dev->flags & IFF_UP) test.

Thanks for the patch.  It's running OK so far, but I'll need to
do a bunch more testing tomorrow to make sure I'm not just getting
lucky!

I'll let you know how it goes tomorrow.

Thanks,
Ben



-- 
Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Candela Technologies Inc  http://www.candelatech.com

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
