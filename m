From: Malli <mchilakala@gmail.com>
Subject: Re: ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to zero after unmapping
	the address
Date: Tue, 23 Mar 2010 10:40:34 -0700
Message-ID: <7991c5481003231040u3479778dpcb27d9578383afc0@mail.gmail.com>
References: <201003221759.o2MHxEaj015546@hera.kernel.org>
	 <1269316670.8599.101.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269316670.8599.101.camel@pasglop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 22, 2010 at 8:57 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
> On Mon, 2010-03-22 at 17:59 +0000, Linux Kernel Mailing List wrote:
>> Gitweb: =A0 =A0 http://git.kernel.org/linus/fd3686a842717b890fbe3024=
b83a616c54d5dba0
>> Commit: =A0 =A0 fd3686a842717b890fbe3024b83a616c54d5dba0
>> Parent: =A0 =A0 936332b8e00103fc20eb7e915c9a3bcb2835a11a
>> Author: =A0 =A0 Mallikarjuna R Chilakala <mallikarjuna.chilakala@int=
el.com>
>> AuthorDate: Fri Mar 19 04:41:33 2010 +0000
>> Committer: =A0David S. Miller <davem@davemloft.net>
>> CommitDate: Fri Mar 19 21:00:44 2010 -0700
>>
>> =A0 =A0 ixgbe: Set IXGBE_RSC_CB(skb)->DMA field to zero after unmapp=
ing the address
>>
>> =A0 =A0 As per Simon Horman's feedback set IXGBE_RSC_CB(skb)->dma to=
 zero
>> =A0 =A0 after unmapping HWRSC DMA address to avoid double freeing.
>>
>
> Note that this whole code is bogus :-) You cannot just assume that 0 =
is
> a invalid DMA address. It is not. In fact, while you can check if a
> dma_addr_t is invalid using dma_mapping_error(), the generic APIs
> don't provide you with a magic "bad" value you can use for what you a=
re
> trying to do.
>
> Granted, I think we should make our iommu code reserve the first page
> for the sake of everybody's sanity and to avoid such pitfalls, but
> this code is wrong with today iommu implementations.
>
> Cheers,
> Ben.

Yes. I just realized that i can't assign a zero magic "bad" value. It i=
s only
valid in x86/arm/m68k/alpha architecures and not in spark & PowerPC arc=
h,
(it should be ~0). In some other architecutres it throws a BUG() on wit=
h
dma_mapping_error() checks. So the patch is not a total bogus in some
architectures :(.

May be it is best to create an internal FLAG in IXGBE_RSC_CB(skb)
which can be used to avoid this double freeing.
