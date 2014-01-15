From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next 0/4] net_cls for sys container
Date: Tue, 14 Jan 2014 16:50:11 -0800
Message-ID: <87y52idq64.fsf@xmission.com>
References: <52C62A44.4070304@huawei.com>
	<CAM_iQpW0+Ftvk=QBE+0yMNW00VkBee1+yAEmbPkT+zjij9RX-Q@mail.gmail.com>
	<52CA614D.6040702@huawei.com> <52CA6C80.9060002@cn.fujitsu.com>
	<52CA8026.4010106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <52CA8026.4010106-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> (Libo Chen's message of "Mon, 6 Jan
	2014 18:06:30 +0800")
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> writes:

> yes
> On 2014/1/6 16:42, Gao feng wrote:
>> On 01/06/2014 03:54 PM, Libo Chen wrote:
>>> On 2014/1/3 13:20, Cong Wang wrote:
>>>> On Thu, Jan 2, 2014 at 7:11 PM, Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
>>>>> Hi guys,
>>>>>
>>>>> Now, lxc created with veth can not be under control by
>>>>> cls_cgroup.
>>>>>
>>>>> the former discussion:
>>>>> http://lkml.indiana.edu/hypermail/linux/kernel/1312.1/00214.html
>>>>>
>>>>> In short, because cls_cgroup relys classid attached to sock
>>>>> filter skb, but sock will be cleared inside dev_forward_skb()
>>>>> in veth_xmit().
>>>>
>>>>
>>>> So what are you trying to achieve here?
>>>
>>> sys container using veth can be controlled by cls_cgroup basing on physic network interface
>>>
>> 
>> It's a problem about virtual nic, not container/net namespace.
>
> yes
>
>> 
>> If veth device is running in host. the skb is transmitted firstly by veth device and then delivered
>> by physical device. if you set both qdisc rule on veth and physical device. which qdisc rule will take
>> effect?
>
> both, the end result depends on a smaller.
>
>> 
>> In your patch, both qdisc rule are effective. it looks strange.
>> 
>
> qdisc is based nic, does not distinguish virtual or physics. if you are all set,
> it means that what you want.  so the logic is not the problemI and this appears to be normal.

My personal opinion on the matter is that the network class cgroup is
brain dead and should not be used.  It is impossible to use for
incomming packets, and it is part of the the problem plagued cgroup
subsystem.

You have real network interfaces to do your classification with you
don't need to enhance the network class cgroup.

The more this is asked about the more I think the network class cgroup
should be be taken out into the woods some dark night and left in a
shallow grave, never to bother us again.


Eric
