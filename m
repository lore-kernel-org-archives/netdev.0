From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] module param_call: fix potential NULL pointer dereference
Date: Mon, 22 Feb 2010 19:41:21 +1030
Message-ID: <201002221941.21662.rusty@rustcorp.com.au>
References: <1266737078-26186-1-git-send-email-dongdong.deng@windriver.com> <2375c9f91002210041l1bf30871vdf3881589a654d5a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dongdong Deng <dongdong.deng@windriver.com>, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jason.wessel@windriver.com, lenb@kernel.org, dwmw2@infradead.org,
	mdharm-usb@one-eyed-alien.net, bfields@fieldses.org,
	robert.richter@amd.com
To: =?iso-8859-15?q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2375c9f91002210041l1bf30871vdf3881589a654d5a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 21 Feb 2010 07:11:36 pm Am=E9rico Wang wrote:
> On Sun, Feb 21, 2010 at 3:24 PM, Dongdong Deng
> <dongdong.deng@windriver.com> wrote:
> > The param_set_fn() function will get a parameter which is a NULL
> > pointer when insmod module with params via following method:
> >
> > $insmod module.ko module_params
> >
> > BTW: the normal method usually as following format:
> > $insmod module.ko module_params=3Dexample
> >
> > If the param_set_fn() function didn't check that parameter and used
> > it directly, it could caused an OOPS due to NULL pointer dereferenc=
e.
> >
> > The solution is simple:
> > Just checking the parameter before using in param_set_fn().
> >
> > Example:
> > int set_module_params(const char *val, struct kernel_param *kp)
> > {
> >        /*Checking the val parameter before using */
> >        if (!val)
> >                return -EINVAL;
> >        ...
> > }
> > module_param_call(module_params, set_module_params, NULL, NULL, 064=
4);
> >
>=20
> Why not just checking all of them in the generic code?

It seemed useful to allow 'foo' as well as 'foo=3D'.  But given these e=
xamples,
obviously that was too easy to misuse.

So I like your patch; please annotate it properly and put a comment
like:
	/* We used to hand NULL for bare params, but most code didn't handle i=
t :( */

I assume none of those non-standard param parsers *want* to handle NULL=
?

Thanks,
Rusty.
--=20
Away travelling 25Feb-26Mar (6 .de + 1 .pl + 17 .lt + 2 .sg)
