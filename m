From: Niranjan <niranjan_cs2905@yahoo.com>
Subject: Re: kernel bug at sched.c:564! + linux kernel 2.4.25
Date: Tue, 27 Jul 2004 15:23:33 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040727222333.14936.qmail@web53005.mail.yahoo.com>
References: <200407272150.50664.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, Niranjan <niranjan_cs2905@yahoo.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>, James Morris <jmorris@redhat.com>
In-Reply-To: <200407272150.50664.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thanks for all your help. I didn't found any group
which is maintaining CryptoAPI.
I am using cryptoapi-0.1.0 and there is no
crypto/api.c file. But the memory allocation in this
version (cryptoapi-0.1.0) is using GFP_KERNEL.
I really didn't understand how to solve the problem
using BH. Now, I am reading kernel locking HOWTO to
understand BH and softirq.
I will also try adding crypto functions inside the
WLAN driver.

Warm Regards,
-Niranjan
UMASS.


--- Vladimir Kondratiev <vkondra@mail.ru> wrote:
> On Tuesday 27 July 2004 21:39, James Morris wrote:
> > On Tue, 27 Jul 2004, Vladimir Kondratiev wrote:
> > > We also saw the same (crypto modules goes to
> sleep).
> > > Due to this, we decided to not use cryptoapi for
> our wireless driver, but
> > > compile the same crypto functions into the
> driver. I know this is code
> > > duplication, but Tx and Rx paths work in BH
> context (I reschedule it on
> > > IRQ Rx to use cheaper time).
> > >
> > > Do cryptoapi maintainers aware of this issue?
> >
> > The crypto functions should be safe to use in
> softirq context.
> It should be, but:
> <crypto/api.c:121>
> struct crypto_tfm *crypto_alloc_tfm(const char
> *name, u32 flags)
> {
>         struct crypto_tfm *tfm = NULL;
>         struct crypto_alg *alg;
> 
>         alg = crypto_alg_mod_lookup(name);
>         if (alg == NULL)
>                 goto out;
> 
>         tfm = kmalloc(sizeof(*tfm) +
> alg->cra_ctxsize, GFP_KERNEL);
> 
> Note kmalloc(GFP_KERNEL)
> >
> >
> > - James
> 

> ATTACHMENT part 2 application/pgp-signature 




		
__________________________________
Do you Yahoo!?
Yahoo! Mail - 50x more storage than other providers!
http://promotions.yahoo.com/new_mail
