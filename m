From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Fri, 3 Mar 2017 15:57:17 +0100
Message-ID: <20170303145717.GJ6536@twins.programming.kicks-ass.net>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-3-arnd@arndb.de>
 <76790664-a7a9-193c-2e30-edaee1308cb0@de.ibm.com>
 <CAK8P3a082Bi6Vf5gEFLAJtJvUm=7MtddBzcCOqagQyfJPFTu_g@mail.gmail.com>
 <2adc6ff4-5dc5-8f1d-cce1-47f3124a528f@de.ibm.com>
 <CAK8P3a2mepCjPfM9Ychk7CHFHi0UW8RBzK4skJKMSOjw3gKoYg@mail.gmail.com>
 <f86cf852-3960-0dcf-5917-509080ca7bf5@de.ibm.com>
 <20170303144938.GF6557@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>,
        kasan-dev <kasan-dev@googlegroups.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Alexander Potapenko <glider@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Networking <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-media@vger.kernel.org,
        linux-wireless <linux-wireless@vger.kernel.org>,
        kernel-build-reports@lists.linaro.org,
        "David S . Miller" <davem@davemloft.net>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <linux-media-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170303144938.GF6557@twins.programming.kicks-ass.net>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2017 at 03:49:38PM +0100, Peter Zijlstra wrote:
> On Fri, Mar 03, 2017 at 09:26:50AM +0100, Christian Borntraeger wrote:
> > Right. The main purpose is to read/write _ONCE_. You can assume a somewhat
> > atomic access for sizes <= word size. And there are certainly places that
> > rely on that. But the *ONCE thing is mostly used for things where we used
> > barrier() 10 years ago.
> 
> A lot of code relies on READ/WRITE_ONCE() to generate single
> instructions for naturally aligned machined word sized loads/stores
> (something GCC used to guarantee, but does no longer IIRC).
> 
> So much so that I would say its a bug if READ/WRITE_ONCE() doesn't
> generate a single instruction under those conditions.
> 
> However, every time I've tried to introduce stricter
> semantics/primitives to verify things Linus hated it.

See here for the last attempt:

  https://marc.info/?l=linux-virtualization&m=148007765918101&w=2
