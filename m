From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: x_tables: allow to use cgroup match for
 LOCAL_IN nf hooks
Date: Wed, 26 Mar 2014 11:15:38 +0100
Message-ID: <20140326101538.GA5131@localhost>
References: <1395212322-12508-1-git-send-email-a.perevalov@samsung.com>
 <532964D3.4070002@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Perevalov <a.perevalov@samsung.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, kyungmin.park@samsung.com,
	john.stultz@linaro.org, edumazet@google.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <532964D3.4070002@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 19, 2014 at 10:35:15AM +0100, Daniel Borkmann wrote:
> On 03/19/2014 07:58 AM, Alexey Perevalov wrote:
> >This simple modification allows iptables to work with INPUT chain
> >in combination with cgroup module. It could be useful for counting
> >ingress traffic per cgroup with nfacct netfilter module. There
> >were no problems to count the egress traffic that way formerly.
> >
> >It's possible to get classified sk_buff after PREROUTING, due to
> >socket lookup being done in early_demux (tcp_v4_early_demux). Also
> >it works for udp as well.
> >
> >Trivial usage example, assuming we're in the same shell every step
> >and we have enough permissions:
> >
> >1) Classic net_cls cgroup initialization:
> >
> >   mkdir /sys/fs/cgroup/net_cls
> >   mount -t cgroup -o net_cls net_cls /sys/fs/cgroup/net_cls
> >
> >2) Set up cgroup for interesting application:
> >
> >   mkdir /sys/fs/cgroup/net_cls/wget
> >   echo 1 > /sys/fs/cgroup/net_cls/wget/net_cls.classid
> >   echo $BASHPID > /sys/fs/cgroup/net_cls/wget/cgroup.procs
> >
> >3) Create kernel counters:
> >
> >   nfacct add wget-cgroup-in
> >   iptables -A INPUT -m cgroup ! --cgroup 1 -m nfacct --nfacct-name wget-cgroup-in
> >
> >   nfacct add wget-cgroup-out
> >   iptables -A OUTPUT -m cgroup ! --cgroup 1 -m nfacct --nfacct-name wget-cgroup-out
> >
> >4) Network usage:
> >
> >   wget https://www.kernel.org/pub/linux/kernel/v3.x/testing/linux-3.14-rc6.tar.xz
> >
> >5) Check results:
> >
> >   nfacct list
> >
> >Cgroup approach is being used for the DataUsage (counting & blocking
> >traffic) feature for Samsung's modification of the Tizen OS.
> >
> >Signed-off-by: Alexey Perevalov <a.perevalov@samsung.com>
> 
> Acked-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
