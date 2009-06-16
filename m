From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT]: Networking
Date: Tue, 16 Jun 2009 11:26:35 +0200
Message-ID: <20090616092635.GB4184@elte.hu>
References: <20090615.050449.144947903.davem@davemloft.net> <20090616091538.GA4184@elte.hu> <20090616.022131.267374816.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756586AbZFPJ0x@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090616.022131.267374816.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 16 Jun 2009 11:15:38 +0200
> 
> > BUG: sleeping function called from invalid context at net/core/sock.c:1851
> 
> This line in my tree (and Linus's) reads:
> 
> 	if (sk->sk_lock.owned)
> 
> what gives? :-)

hmmm - i have to declare the small kmemcheck annotation attached 
below :-)

(kmemcheck is off in the config so it shouldnt matter)

So the line is:

        might_sleep();

Lemme dig.

	Ingo

diff --git a/net/core/sock.c b/net/core/sock.c
index 06e26b7..b0ba569 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -945,6 +945,8 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
 		sk = kmalloc(prot->obj_size, priority);
 
 	if (sk != NULL) {
+		kmemcheck_annotate_bitfield(sk, flags);
+
 		if (security_sk_alloc(sk, family, priority))
 			goto out_free;
 
