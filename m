From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Poll about irqsafe_cpu_add and others
Date: Thu, 17 Mar 2011 19:29:29 +0100
Message-ID: <1300386569.6315.404.camel@edumazet-laptop>
References: <1300371834.6315.93.camel@edumazet-laptop>
	 <20110317.081420.71114992.davem@davemloft.net>
	 <alpine.DEB.2.00.1103171016270.12540@router.home>
	 <1300380801.6315.306.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1103171245430.16620@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1103171245430.16620@router.home>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 17 mars 2011 =C3=A0 12:46 -0500, Christoph Lameter a =C3=A9cri=
t :
> On Thu, 17 Mar 2011, Eric Dumazet wrote:
>=20
> > When we know we run from BH context, we can use __this_cpu_inc(), b=
ut if
> > we dont know or run from user/process context, we would need irqsaf=
e_inc
> > variant.
>=20
> If the BH context is the only one where we care about performance the=
n its
> ok I would think.

Hmm... yes.

By the way, I noticed :

DECLARE_PER_CPU(u64, xt_u64);
__this_cpu_add(xt_u64, 2) translates to following x86_32 code :

	mov	$xt_u64,%eax
	add	%fs:0x0,%eax
	addl	$0x2,(%eax)
	adcl	$0x0,0x4(%eax)


I wonder why we dont use :

	addl	$0x2,%fs:xt_u64
	addcl	$0x0,%fs:xt_u64+4



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
