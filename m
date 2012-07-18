From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2] netns: correctly use per-netns ipv4 sysctl_tcp_mem
Date: Wed, 18 Jul 2012 09:41:37 -0700 (PDT)
Message-ID: <20120718.094137.2279894799753732191.davem@davemloft.net>
References: <4FFE99EE.70003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4FFE99EE.70003-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
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

From: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Date: Thu, 12 Jul 2012 17:33:34 +0800

> From: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> Now, kernel allows each net namespace to independently set up its levels
> for tcp memory pressure thresholds.
> 
> But it seems there is a bug, as using the following steps:
> 
> [root@host socket]# lxc-start -n test -f config /bin/bash
> [root@net-test socket]# ip route add default via 192.168.58.2
> [root@net-test socket]# echo 0 0 0 > /proc/sys/net/ipv4/tcp_mem
> [root@net-test socket]# scp root-Q0ErXNX1RuabR28l3DCWlg@public.gmane.org:/home/tcp_mem_test .
> 
> and it still can transport the "tcp_mem_test" file which we hope it
> would not.
> 
> It's because inet_init() (net/ipv4/af_inet.c)initialize the tcp_prot.sysctl_mem:
> tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
> 
> So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)
> always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
> it's own net namespace.
> This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
> the protocol type is TCP.
> 
> Signed-off-by: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

This patch doesn't apply cleanly to net-next, please respin it.

Thank you.
