From: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Re: [PATCH] p54pci: don't return zero on failure path in p54p_probe()
Date: Wed, 2 Jan 2013 00:53:18 +0100
Message-ID: <201301020053.18704.chunkeey@googlemail.com>
References: <1357074661-15784-1-git-send-email-khoroshilov@ispras.ru> <201301012245.43064.chunkeey@googlemail.com> <50E366D6.7040709@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-tpLiQldItUH5n4uC9ZG1Ww@public.gmane.org
To: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50E366D6.7040709-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 01 January 2013 23:44:38 Alexey Khoroshilov wrote:
> On 01/02/2013 01:45 AM, Christian Lamparter wrote:
> > On Tuesday 01 January 2013 22:11:01 Alexey Khoroshilov wrote:
> >> If pci_set_dma_mask() or pci_set_consistent_dma_mask() fails in p54p_probe(),
> >> it breaks off initialization, deallocates all resources, but returns zero.
> >>
> >> The patch implements proper error code propagation.
> > Uh, Thanks!
> >
> > But wait, I think there's another return 0 in the error
> > path. See p54pci.c @ line 558:
> >
> > mem_len = pci_resource_len(pdev, 0);
> > if (mem_len < sizeof(...)) {
> > 	dev_err(...)
> > 	goto err_disabled_dev;
> > }
> >
> > Do you think you can add a err = -EINVAL; before the goto too?
> You are right! But I would say -ENODEV is more popular error code in 
> this case.
pci_* functions seem to use a lot of -EIO too. Either way shouldn't
really matter. So, let's make it -ENODEV.
 
> > [I wonder why this wasn't found by the verification project as
> > well? Could it be that pci_resource_len(...) < sizeof(...) is
> > somehow always true and this is a dead branch?]
> Actually it was found, but I have no direct access to the results at the 
> moment. My fault.
> 
> Would you like I resend the patch to fix both?
:)

Don't forget the ACKed-by tag from the previous reply!

Thanks

Christian
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
