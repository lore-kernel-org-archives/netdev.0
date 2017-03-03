From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH 02/26] rewrite READ_ONCE/WRITE_ONCE
Date: Fri, 3 Mar 2017 15:49:38 +0100
Message-ID: <20170303144938.GF6557@twins.programming.kicks-ass.net>
References: <20170302163834.2273519-1-arnd@arndb.de>
 <20170302163834.2273519-3-arnd@arndb.de>
 <76790664-a7a9-193c-2e30-edaee1308cb0@de.ibm.com>
 <CAK8P3a082Bi6Vf5gEFLAJtJvUm=7MtddBzcCOqagQyfJPFTu_g@mail.gmail.com>
 <2adc6ff4-5dc5-8f1d-cce1-47f3124a528f@de.ibm.com>
 <CAK8P3a2mepCjPfM9Ychk7CHFHi0UW8RBzK4skJKMSOjw3gKoYg@mail.gmail.com>
 <f86cf852-3960-0dcf-5917-509080ca7bf5@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        kasan-dev <kasan-dev-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
        Andrey Ryabinin <aryabinin-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>,
        Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Networking <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-build-reports-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Paul McKenney <paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
To: Christian Borntraeger <borntraeger-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <f86cf852-3960-0dcf-5917-509080ca7bf5-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 03, 2017 at 09:26:50AM +0100, Christian Borntraeger wrote:
> Right. The main purpose is to read/write _ONCE_. You can assume a somewhat
> atomic access for sizes <= word size. And there are certainly places that
> rely on that. But the *ONCE thing is mostly used for things where we used
> barrier() 10 years ago.

A lot of code relies on READ/WRITE_ONCE() to generate single
instructions for naturally aligned machined word sized loads/stores
(something GCC used to guarantee, but does no longer IIRC).

So much so that I would say its a bug if READ/WRITE_ONCE() doesn't
generate a single instruction under those conditions.

However, every time I've tried to introduce stricter
semantics/primitives to verify things Linus hated it.
