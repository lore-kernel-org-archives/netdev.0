From: Shan Wei <shanwei88@gmail.com>
Subject: Re: [PATCH 3/9] net: xfrm: use this_cpu_ptr per-cpu helper
Date: Thu, 01 Nov 2012 16:56:54 +0800
Message-ID: <50923956.5090206@gmail.com>
References: <509109F9.3030904@gmail.com> <0000013ab7e4a640-60bd5b38-a1fc-4730-b918-4109211ffea0-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>
To: Christoph Lameter <cl@linux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0000013ab7e4a640-60bd5b38-a1fc-4730-b918-4109211ffea0-000000@email.amazonses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter said, at 2012/11/1 1:35:
> It would be better to use
>=20
> 	this_cpu_read(tfms)
>=20
> since that would also make it atomic vs interrupts. The above code (b=
oth
> original and modified) could determine a pointer to a per cpu structu=
re
> and then take an interrupt which would move the task. On return we wo=
uld
> be accessing the per cpu variable of another processor.

this_cpu_read
|-----_this_cpu_generic_read

#define _this_cpu_generic_read(pcp)                                    =
 \
({      typeof(pcp) ret__;                                             =
 \
        preempt_disable();                                             =
 \
        ret__ =3D *this_cpu_ptr(&(pcp));                               =
   \
        preempt_enable();                                              =
 \
        ret__;                                                         =
 \
})


this_cpu_read operations locate per-cpu variable with preemption safe=EF=
=BC=8C not
disable interrupts. why is it atomic vs interrupts?

I have no idea whether we need to disable preemption for this code?
At least, xfrm code run well with per_cpu_ptr which don't disable preem=
ption.
