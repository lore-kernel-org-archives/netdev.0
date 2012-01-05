From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/6] net: add paged frag destructor
 support to kernel_sendpage.
Date: Thu, 05 Jan 2012 14:15:22 -0500 (EST)
Message-ID: <20120105.141522.1303730212186060591.davem@davemloft.net>
References: <1325783399.25206.413.camel@zakaz.uk.xensource.com>
	<1325783624-14601-5-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, rds-devel@oss.oracle.com, pekkas@netcore.fi,
        eric.dumazet@gmail.com, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, gregkh@suse.de, Trond.Myklebust@netapp.com,
        jmorris@namei.org, cluster-devel@redhat.com,
        ocfs2-devel@oss.oracle.com, kuznet@ms2.inr.ac.ru,
        ceph-devel@vger.kernel.org, linux-nfs@vger.kernel.org, kaber@trash.net,
        drbd-user@lists.linbit.com
To: ian.campbell@citrix.com
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1325783624-14601-5-git-send-email-ian.campbell@citrix.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

From: Ian Campbell <ian.campbell@citrix.com>
Date: Thu, 5 Jan 2012 17:13:43 +0000

> -static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffset,
> +static ssize_t do_tcp_sendpages(struct sock *sk,
> +				struct page **pages,
> +				struct skb_frag_destructor **destructors,
> +				int poffset,
>  			 size_t psize, int flags)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);

An array of destructors is madness, and the one call site that specifies this
passes an address of a single entry.

This also would never even have to occur if you put the destructor inside of
struct page instead.

Finally, except for the skb_shared_info() layout optimization in patch #1 which
I alreayd applied, this stuff is not baked enough for the 3.3 merge window.
