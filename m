From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 16/16] rxrpc: Replace smp_read_barrier_depends() with lockless_dereference()
Date: Thu, 13 Nov 2014 20:17:39 +0000
Message-ID: <24350.1415909859@warthog.procyon.org.uk>
References: <1415906662-4576-17-git-send-email-bobby.prani@gmail.com> <1415906662-4576-1-git-send-email-bobby.prani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list),
	paulmck@linux.vnet.ibm.com
To: Pranith Kumar <bobby.prani@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415906662-4576-17-git-send-email-bobby.prani@gmail.com>
Content-ID: <24349.1415909859.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pranith Kumar <bobby.prani@gmail.com> wrote:

>  	     loop != call->acks_head || stop;
>  	     loop = (loop + 1) &  (call->acks_winsz - 1)
>  	     ) {
> -		p_txb = call->acks_window + loop;
> -		smp_read_barrier_depends();
> +		p_txb = lockless_dereference(call)->acks_window + loop;

Nack.  You've stuck an implicit barrier on a dereference that doesn't matter.
And similar for other hunks of this patch.

David
