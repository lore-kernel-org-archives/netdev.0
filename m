From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] unix: avoid use-after-free in ep_remove_wait_queue
Date: Mon, 09 Nov 2015 13:25:23 -0500 (EST)
Message-ID: <20151109.132523.624907753522887529.davem@davemloft.net>
References: <563CC002.5050307@akamai.com>
	<87ziyrcg67.fsf@doppelsaurus.mobileactivedefense.com>
	<87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbaron@akamai.com, dvyukov@google.com, syzkaller@googlegroups.com,
	mkubecek@suse.cz, viro@zeniv.linux.org.uk,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	hannes@stressinduktion.org, dhowells@redhat.com,
	paul@paul-moore.com, salyzyn@android.com, sds@tycho.nsa.gov,
	ying.xue@windriver.com, netdev@vger.kernel.org, kcc@google.com,
	glider@google.com, andreyknvl@google.com, sasha.levin@oracle.com,
	jln@google.com, keescook@google.com, minipli@googlemail.com
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87fv0fnslr.fsf_-_@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Mon, 09 Nov 2015 14:40:48 +0000

> +	__remove_wait_queue(&unix_sk(u->peer_wake.private)->peer_wait,
> +			    &u->peer_wake);

This is more simply:

	__remove_wait_queue(&unix_sk(u->peer_wake.private)->peer_wait, q);

> +static inline int unix_dgram_peer_recv_ready(struct sock *sk,
> +					     struct sock *other)

Please do not us the inline keyword in foo.c files, let the compiler
decide.

Thanks.
