From: David Miller <davem@davemloft.net>
Subject: Re: [RFC,PATCH] loopback: calls netif_receive_skb() instead of
 netif_rx()
Date: Mon, 31 Mar 2008 03:08:48 -0700 (PDT)
Message-ID: <20080331.030848.175668431.davem@davemloft.net>
References: <20080323.032949.194309002.davem@davemloft.net>
	<47E6A5FD.6060407@cosmosbay.com>
	<20080331094823.GA11651@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl
To: mingo@elte.hu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756093AbYCaKI6@vger.kernel.org>
In-Reply-To: <20080331094823.GA11651@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 31 Mar 2008 11:48:23 +0200

> 
> * Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > I noticed some paths in kernel are very stack aggressive, and on i386 
> > with CONFIG_4KSTACKS we were really in a dangerous land, even without 
> > my patch.
> >
> > What we call 4K stacks is in fact 4K - sizeof(struct task_struct), so 
> > a litle bit more than 2K. [...]
> 
> that's just wrong - 4K stacks on x86 are 4K-sizeof(thread_info) - the 
> task struct is allocated elsewhere. The patch below runs just fine on 
> 4K-stack x86.

I don't think it's safe.

Every packet you receive can result in a sent packet, which
in turn can result in a full packet receive path being
taken, and yet again another sent packet.

And so on and so forth.

Some cases like this would be stack bugs, but wouldn't
you like that bug to be a very busy cpu instead of a
crash from overrunning the current stack?
