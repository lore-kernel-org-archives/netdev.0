From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: Re: [PATCH 4/9] powerpc: inline ip_fast_csum()
Date: Mon, 29 Feb 2016 08:25:59 +0100
Message-ID: <56D3F287.6020707@c-s.fr>
References: <cover.1442876807.git.christophe.leroy@c-s.fr>
 <807dbc9449077e36752c649c09ae1c0d70e45254.1442876807.git.christophe.leroy@c-s.fr>
 <CAOJe8K0+duRrj19OoPjdoX725Jwh4T=im=_aCp+N8UTNudp=3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>, scottwood@freescale.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOJe8K0+duRrj19OoPjdoX725Jwh4T=im=_aCp+N8UTNudp=3w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Le 23/09/2015 07:43, Denis Kirjanov a =C3=A9crit :
> On 9/22/15, Christophe Leroy <christophe.leroy@c-s.fr> wrote:
>> In several architectures, ip_fast_csum() is inlined
>> There are functions like ip_send_check() which do nothing
>> much more than calling ip_fast_csum().
>> Inlining ip_fast_csum() allows the compiler to optimise better
> Hi Christophe,
> I did try it and see no difference on ppc64. Did you test with sockli=
b
> with modified loopback and if so do you have any numbers?

Hi Denis,

I put a mftbl at start and end of ip_send_check() and tested on a MPC88=
5:
* Without ip_fast_csum() inlined, approxymatly 7 TB ticks are spent in=20
ip_send_check()
* With ip_fast_csum() inlined, approxymatly 5,4 TB ticks are spent in=20
ip_send_check()

So it is about 23% time reduction.

Christophe
