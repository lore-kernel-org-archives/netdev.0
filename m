From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] locking bug in fib_semantics.c
Date: Tue, 22 Aug 2006 12:35:56 +0200
Message-ID: <20060822103556.GA3262@ff.dom.local>
References: <20060817093615.GA25553@ms2.inr.ac.ru> <20060821081642.GA2637@ff.dom.local> <20060821.011703.78716718.davem@davemloft.net> <20060821110201.GA3674@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:44928 "EHLO poczta.o2.pl")
	by vger.kernel.org with ESMTP id S932156AbWHVKc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 06:32:58 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060821110201.GA3674@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 01:02:01PM +0200, Jarek Poplawski wrote:
> On 21-08-2006 10:17, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@o2.pl>
> > Date: Mon, 21 Aug 2006 10:16:43 +0200
> ...
> > I was skeptical of this case too, until I checked how
> > fib_release_info() was called.
> 
> I overlooked this - so I've to sharpen my sight and look at it 
> again - now knowing it's there.
...

Hello,
I've found it at last but on that occasion I've got some
doubt according to rcu_read_lock and rcu_call treatment:
isn't it "illegal to block while in an RCU read-side
section"? And I think it takes place in:

fib_lookup(): from tb_insert (fn_hash_insert() or
  fn_trie_insert()), fib_create_info(), fib_check_nh() 

fn_trie_lookup(): like above, inet_addr_type(),
  tb_lookup()

fib_rule_put(): like #1 above or #2 after tb_lookup(),
  fib_res_put()

Shouldn't there be _bh also?

Jarek P.

PS: linux-2.6.18-rc4
