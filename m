From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC PATCH net-next 0/4] net_cls for sys container
Date: Mon, 06 Jan 2014 16:42:40 +0800
Message-ID: <52CA6C80.9060002@cn.fujitsu.com>
References: <52C62A44.4070304@huawei.com>
	<CAM_iQpW0+Ftvk=QBE+0yMNW00VkBee1+yAEmbPkT+zjij9RX-Q@mail.gmail.com>
	<52CA614D.6040702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>, Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org, Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52CA614D.6040702-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

On 01/06/2014 03:54 PM, Libo Chen wrote:
> On 2014/1/3 13:20, Cong Wang wrote:
>> On Thu, Jan 2, 2014 at 7:11 PM, Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org> wrote:
>>> Hi guys,
>>>
>>> Now, lxc created with veth can not be under control by
>>> cls_cgroup.
>>>
>>> the former discussion:
>>> http://lkml.indiana.edu/hypermail/linux/kernel/1312.1/00214.html
>>>
>>> In short, because cls_cgroup relys classid attached to sock
>>> filter skb, but sock will be cleared inside dev_forward_skb()
>>> in veth_xmit().
>>
>>
>> So what are you trying to achieve here?
> 
> sys container using veth can be controlled by cls_cgroup basing on physic network interface
> 

It's a problem about virtual nic, not container/net namespace.

If veth device is running in host. the skb is transmitted firstly by veth device and then delivered
by physical device. if you set both qdisc rule on veth and physical device. which qdisc rule will take
effect?

In your patch, both qdisc rule are effective. it looks strange.
