From: Libo Chen <clbchenlibo.chen-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: cgroup filter on physics interface can't control container
Date: Thu, 12 Dec 2013 20:18:07 +0800
Message-ID: <52A9A97F.20902@huawei.com>
References: <52A52BBF.6030105@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	honkiko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	"zhangwei\(Jovi\)" <jovi.zhangwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52A52BBF.6030105-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

ping...

On 2013/12/9 10:32, Libo Chen wrote:
> hello network hackers,
> 
> 	A linux container was builded with veth pair(veth0 inside container, veth1 outside container),
> 
> the config as below:
> 
>   lxc.network.type = veth
>   lxc.network.flags = up
>   lxc.network.link = br0  // base on eth0
>   lxc.network.name = eth0
>   lxc.network.ipv4 = 128.5.130.26/24
> 
> then I use tc command with cgroup filter on veth0, it works well. But when setting on eth0, it doesn`t work.
> 
> The reason is dev_forward_skb() in veth_xmit will call skb_scrub_packet and clean all information including skb->sk
> in the skb, so if cls_cgroup_classify is working in serving softirq state, it will return failer, see below:
> 
> 	if (in_serving_softirq()) {
> 		/* If there is an sk_classid we'll use that. */
> 		if (!skb->sk)
> 			return -1;
> 		classid = skb->sk->sk_classid;
> 	}
> 
> 
> Qdisc with cgroup filter on physics interface can not control a container network, it is disappointed.
> 
> we can save sk_classid before skb_scrub_packet and restore it after that. Is it reasonable?  or any way to achieve this?
> 
> thanks,
> Libo
> 
