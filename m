From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 3/9] net: xfrm: use this_cpu_ptr per-cpu helper
Date: Thu, 1 Nov 2012 10:18:42 +0100
Message-ID: <20121101091842.GA2719@secunet.com>
References: <509109F9.3030904@gmail.com>
 <0000013ab7e4a640-60bd5b38-a1fc-4730-b918-4109211ffea0-000000@email.amazonses.com>
 <50923956.5090206@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:35338 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752145Ab2KAJSw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Nov 2012 05:18:52 -0400
Content-Disposition: inline
In-Reply-To: <50923956.5090206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 01, 2012 at 04:56:54PM +0800, Shan Wei wrote:
> Christoph Lameter said, at 2012/11/1 1:35:
> > It would be better to use
> >=20
> > 	this_cpu_read(tfms)
> >=20
> > since that would also make it atomic vs interrupts. The above code =
(both
> > original and modified) could determine a pointer to a per cpu struc=
ture
> > and then take an interrupt which would move the task. On return we =
would
> > be accessing the per cpu variable of another processor.
>=20
> this_cpu_read
> |-----_this_cpu_generic_read
>=20
> #define _this_cpu_generic_read(pcp)                                  =
   \
> ({      typeof(pcp) ret__;                                           =
   \
>         preempt_disable();                                           =
   \
>         ret__ =3D *this_cpu_ptr(&(pcp));                             =
     \
>         preempt_enable();                                            =
   \
>         ret__;                                                       =
   \
> })
>=20
>=20
> this_cpu_read operations locate per-cpu variable with preemption safe=
=EF=BC=8C not
> disable interrupts. why is it atomic vs interrupts?
>=20
> I have no idea whether we need to disable preemption for this code?
> At least, xfrm code run well with per_cpu_ptr which don't disable pre=
emption.

We compare the name of the newly allocated crypto transform against the
existing ones. The name is the same on every percpu transform and it
does not change after the transform is allocated. So we don't care
if we get migrated or not, we can just take the transform from an
arbitrary cpu to read the name from it.
