From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Mon, 22 Aug 2011 08:45:03 +0200
Message-ID: <1313995503.2598.15.camel@edumazet-laptop>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <4DEB3AE4.8040700@redhat.com>  <4DEB8872.2060801@fnarfbargle.com>
	 <1307391746.2642.11.camel@edumazet-laptop>
	 <4DEE273F.7090402@fnarfbargle.com>
	 <1307453874.3091.14.camel@edumazet-laptop>
	 <4E4FB3B7.4040501@fnarfbargle.com>  <4E51F8D4.5070804@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Brad Campbell <lists2009@fnarfbargle.com>, CaT <cat@zip.com.au>,
	Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4E51F8D4.5070804@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 22 ao=C3=BBt 2011 =C3=A0 09:36 +0300, Avi Kivity a =C3=A9crit =
:
> On 08/20/2011 04:16 PM, Brad Campbell wrote:
> > Author: Alexander Duyck <alexander.h.duyck@intel.com>
> > Date:   Thu Jul 1 13:28:27 2010 +0000
> >
> >     x86: Drop CONFIG_MCORE2 check around setting of NET_IP_ALIGN
> >
> >     This patch removes the CONFIG_MCORE2 check from around=20
> > NET_IP_ALIGN.  It is
> >     based on a suggestion from Andi Kleen.  The assumption is that=20
> > there are
> >     not any x86 cores where unaligned access is really slow, and th=
is=20
> > change
> >     would allow for a performance improvement to still exist on=20
> > configurations
> >     that are not necessarily optimized for Core 2.
> >
> >     Cc: Andi Kleen <ak@linux.intel.com>
> >     Cc: Thomas Gleixner <tglx@linutronix.de>
> >     Cc: Ingo Molnar <mingo@redhat.com>
> >     Cc: "H. Peter Anvin" <hpa@zytor.com>
> >     Cc: x86@kernel.org
> >     Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> >     Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >     Acked-by: H. Peter Anvin <hpa@zytor.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > :040000 040000 5a15867789080a2f67a74b17c4422f85b7a9fb4a=20
> > b98769348bd765731ca3ff03b33764257e23226c M    arch
> >
> > I can confirm this bug exists in the 3.0 kernel, however I'm unable=
 to=20
> > reproduce it on todays git.
> >
> > So anyone using netfilter, kvm and bridge on kernels between=20
> > 2.6.36-rc1 and 3.0 may hit this bug, but it looks like it is fixed =
in=20
> > the current 3.1-rc kernels.
> >
>=20
> Thanks for this effort.  I don't think this patch is buggy in itself,=
 it=20
> merely exposed another bug which was fixed later on.
>=20

Some piece of hardware has a 2-byte offset requirement, and driver
incorrectly assumed NET_IP_ALIGN was 2 on x86.

Brad, could you post your config (lsmod, dmesg) again ?

tg3.c code for example uses a private value, not related to NET_IP_ALIG=
N

#define TG3_RAW_IP_ALIGN 2



