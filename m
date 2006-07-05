From: Avi Kivity <avi@argo.co.il>
Subject: Re: possible recursive locking in ATM layer
Date: Wed, 05 Jul 2006 16:33:11 +0300
Message-ID: <44ABBF97.3070709@argo.co.il>
References: <1152029582.3109.70.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Duncan Sands <duncan.sands@math.u-psud.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>,
	chas@cmf.nrl.navy.mil
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw5.argo.co.il ([194.90.79.130]:45831 "EHLO argo2k.argo.co.il")
	by vger.kernel.org with ESMTP id S964859AbWGENdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2006 09:33:14 -0400
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1152029582.3109.70.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
>
> From: Arjan van de Ven <arjan@linux.intel.com>
>
> > Linux version 2.6.17-git22 (duncan@baldrick) (gcc version 4.0.3 
> (Ubuntu 4.0.3-1ubuntu5)) #20 PREEMPT Tue Jul 4 10:35:04 CEST 2006
>
> >
> > [ 2381.598609] =============================================
> > [ 2381.619314] [ INFO: possible recursive locking detected ]
> > [ 2381.635497] ---------------------------------------------
> > [ 2381.651706] atmarpd/2696 is trying to acquire lock:
> > [ 2381.666354]  (&skb_queue_lock_key){-+..}, at: [<c028c540>] 
> skb_migrate+0x24/0x6c
> > [ 2381.688848]
>
>
> ok this is a real potential deadlock in a way, it takes two locks of 2
> skbuffs without doing any kind of lock ordering; I think the following
> patch should fix it. Just sort the lock taking order by address of the
> skb.. it's not pretty but it's the best this can do in a minimally
> invasive way.
>

Isn't it a deadlock only if skb_migrate(a, b) and skb_migrate(b, a) can 
be called concurrently?

-- 
error compiling committee.c: too many arguments to function

