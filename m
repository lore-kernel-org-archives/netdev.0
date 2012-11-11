From: Krzysztof Mazur <krzysiek@podlesie.net>
Subject: Re: [PATCH v3 8/7] pppoatm: fix missing wakeup in pppoatm_send()
Date: Sun, 11 Nov 2012 19:49:47 +0100
Message-ID: <20121111184947.GA26444@shrek.podlesie.net>
References: <1352240222-363-1-git-send-email-krzysiek@podlesie.net>
 <1352292734.7340.35.camel@shinybook.infradead.org>
 <20121110202338.GA1749@shrek.podlesie.net>
 <1352618933.9449.113.camel@shinybook.infradead.org>
 <20121111110437.GA25894@shrek.podlesie.net>
 <1352633993.9449.120.camel@shinybook.infradead.org>
 <20121111135002.GA32390@shrek.podlesie.net>
 <1352647601.9449.130.camel@shinybook.infradead.org>
 <20121111161219.GA25360@shrek.podlesie.net>
 <1352653401.9449.131.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chas Williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	davem@davemloft.net
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352653401.9449.131.camel@shinybook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 11, 2012 at 05:03:21PM +0000, David Woodhouse wrote:
> On Sun, 2012-11-11 at 17:12 +0100, Krzysztof Mazur wrote:
> > It would require using atomic ops because also pppoatm_pop() can
> > modify this word. I think it's better to add additional word instead
> > of using atomic ops.
> 
> Or use the existing flags word, perhaps. Only one bit of which is
> actually used already. We'd have to filter the new bit out in
> pppoatm_devppp_ioctl().
> 

In pppoatm_devppp_ioctl() we also don't have sk->sk_lock.slock lock.
In original patch synchronization was trivial because callback
from socket lock is used.

I also though about sharing word with encaps enum - encaps needs only 2 bits,
but it's ugly.

Krzysiek
