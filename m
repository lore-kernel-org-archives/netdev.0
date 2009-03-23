From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Mon, 23 Mar 2009 08:50:58 +0000
Message-ID: <20090323085058.GC4976@ff.dom.local>
References: <20090320232943.GA3024@ami.dom.local> <49C74927.7020008@cosmosbay.com> <20090323.013749.122944803.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, vernux@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758215AbZCWIv1@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090323.013749.122944803.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 23, 2009 at 01:37:49AM -0700, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 23 Mar 2009 09:32:39 +0100
> 
> > I dont understand, doesnt it defeat the ticket spinlock thing and fairness ?
> > 
> > Thread doing __qdisc_run() already owns the __QDISC_STATE_RUNNING bit.
> 
> Right.
> 
> Remember, the way this is designed is that if there is a busy
> cpu taking packets out of the queue and putting them into the
> device then other cpus will simply add to the queue and immediately
> return.

But this "busy cpu" can't take packets out of the queue when it's
waiting on the contended spinlock. Anyway, it's only for testing,
and I didn't say it has to be right.

Jarek P.
