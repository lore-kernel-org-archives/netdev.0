From: David Decotigny <ddecotig@gmail.com>
Subject: Re: [PATCH net-next v7 01/19] lib/bitmap.c: conversion routines
 to/from u32 array
Date: Tue, 9 Feb 2016 16:30:51 -0800
Message-ID: <CAG88wWaA-pWcS8CnZykQxoWR4_jZxRhhEeOVQqNK_cOFo=VxFA@mail.gmail.com>
References: <1454893743-6285-1-git-send-email-ddecotig@gmail.com>
 <1454893743-6285-2-git-send-email-ddecotig@gmail.com> <20160208153635.67df5ac2576138088a859087@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-api@vger.kernel.org" <linux-api@vger.kernel.org>,
	linux-mips@linux-mips.org, fcoe-devel@open-fcoe.org,
	Tejun Heo <tj@kernel.org>, Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@emulex.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	Robert Love <robert.w.love@intel.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	Yuval Mintz <Yuval.Mintz@
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160208153635.67df5ac2576138088a859087@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

thanks. done in v8 I am sending right now.

On Mon, Feb 8, 2016 at 3:36 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sun,  7 Feb 2016 17:08:45 -0800 David Decotigny <ddecotig@gmail.com> wrote:
>
>> From: David Decotigny <decot@googlers.com>
>>
>> Aimed at transferring bitmaps to/from user-space in a 32/64-bit agnostic
>> way.
>>
>> Tested:
>>   unit tests (next patch) on qemu i386, x86_64, ppc, ppc64 BE and LE,
>>   ARM.
>>
>> @@ -1060,6 +1062,90 @@ int bitmap_allocate_region(unsigned long *bitmap, unsigned int pos, int order)
>>  EXPORT_SYMBOL(bitmap_allocate_region);
>>
>>  /**
>> + * bitmap_from_u32array - copy the contents of a u32 array of bits to bitmap
>> + *   @bitmap: array of unsigned longs, the destination bitmap, non NULL
>> + *   @nbits: number of bits in @bitmap
>> + *   @buf: array of u32 (in host byte order), the source bitmap, non NULL
>> + *   @nwords: number of u32 words in @buf
>> + *
>> + * copy min(nbits, 32*nwords) bits from @buf to @bitmap, remaining
>> + * bits between nword and nbits in @bitmap (if any) are cleared. In
>> + * last word of @bitmap, the bits beyond nbits (if any) are kept
>> + * unchanged.
>> + */
>
> This will leave the caller not knowing how many valid bits are actually
> present in the resulting bitmap.  To determine that, the caller will
> need to perform (duplicated) math on `nbits' and `nwords'.
>
>> +void bitmap_from_u32array(unsigned long *bitmap, unsigned int nbits,
>> +                       const u32 *buf, unsigned int nwords)
>
> So how about we make this return the number of valid bits in *bitmap?
>
>> +/**
>> + * bitmap_to_u32array - copy the contents of bitmap to a u32 array of bits
>> + *   @buf: array of u32 (in host byte order), the dest bitmap, non NULL
>> + *   @nwords: number of u32 words in @buf
>> + *   @bitmap: array of unsigned longs, the source bitmap, non NULL
>> + *   @nbits: number of bits in @bitmap
>> + *
>> + * copy min(nbits, 32*nwords) bits from @bitmap to @buf. Remaining
>> + * bits after nbits in @buf (if any) are cleared.
>> + */
>> +void bitmap_to_u32array(u32 *buf, unsigned int nwords,
>> +                     const unsigned long *bitmap, unsigned int nbits)
>
> Ditto.
>
>
