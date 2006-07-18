From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 15:51:25 +0400
Message-ID: <20060718115125.GA6087@2ka.mipt.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <200607181316.18461.borntrae@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:14517 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751308AbWGRLv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 07:51:28 -0400
To: Christian Borntraeger <borntrae@de.ibm.com>
Content-Disposition: inline
In-Reply-To: <200607181316.18461.borntrae@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 01:16:18PM +0200, Christian Borntraeger (borntr=
ae@de.ibm.com) wrote:
> Hello Evgeniy,
>=20
> > +asmlinkage long sys_netchannel_control(void __user *arg)
> [...]
> > +	if (copy_from_user(&ctl, arg, sizeof(struct unetchannel_control))=
)
> > +		return -ERESTARTSYS;
>                         ^^^^^^^^^^^
> [...]
> > +	if (copy_to_user(arg, &ctl, sizeof(struct unetchannel_control)))
> > +		return -ERESTARTSYS;
>                         ^^^^^^^^^^^
>=20
> I think this should be -EFAULT instead of -ERESTARTSYS, right?

I have no strong feeling on what must be returned in that case.
As far as I see, copy*user can fail due to absence of the next
destination page, so -ERESTARTSYS makes sence, but if failure happens d=
ue to
process size limitation, -EFAULT is correct.

Let's change it to -EFAULT.

> --=20
> Mit freundlichen Gr=C3=BC=C3=9Fen / Best Regards
>=20
> Christian Borntraeger
> Linux Software Engineer zSeries Linux & Virtualization

--=20
	Evgeniy Polyakov
