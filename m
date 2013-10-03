From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fix unsafe set_memory_rw from softirq
Date: Wed, 02 Oct 2013 21:23:50 -0700
Message-ID: <1380774230.19002.135.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380772231-3566-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Xi Wang <xi.wang@gmail.com>, x86@kernel.org,
	Eric Dumazet <edumazet@google.com>,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380772231-3566-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-10-02 at 20:50 -0700, Alexei Starovoitov wrote:
> on x86 system with net.core.bpf_jit_enable = 1

> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index a6ac848..378fa03 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -27,6 +27,7 @@ struct sk_filter
>  	unsigned int         	len;	/* Number of filter blocks */
>  	unsigned int		(*bpf_func)(const struct sk_buff *skb,
>  					    const struct sock_filter *filter);
> +	struct work_struct	work;
>  	struct rcu_head		rcu;
>  	struct sock_filter     	insns[0];
>  };

Nice catch !

It seems only x86 and s390 needs this work_struct.

(and you might CC Heiko Carstens <heiko.carstens@de.ibm.com> to ask him
to make the s390 part, of Ack it if you plan to do it)

Thanks
