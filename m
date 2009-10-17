From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH 2/8] bitmap: Introduce bitmap_set, bitmap_clear,
	bitmap_find_next_zero_area
Date: Sun, 18 Oct 2009 00:42:04 +0900
Message-ID: <961aa3350910170842w58a72be0id5fbd0e3a5058a1c@mail.gmail.com>
References: <20091013091017.GA18431@localhost.localdomain>
	<20091017224028V.fujita.tomonori@lab.ntt.co.jp>
	<961aa3350910170743n4c9947d1ka0bd31aa1c7b9917@mail.gmail.com>
	<20091017235117U.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: fenghua.yu@intel.com, gregkh@suse.de, tglx@linutronix.de,
	tony.luck@intel.com, x86@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-altix@sgi.com,
	yevgenyp@mellanox.co.il, linuxppc-dev@ozlabs.org,
	mingo@redhat.com, paulus@samba.org, hpa@zytor.com,
	sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org,
	akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	davem@davemloft.net, LW@karo-electronics.de
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20091017235117U.fujita.tomonori@lab.ntt.co.jp>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

>> >> --- a/lib/iommu-helper.c
>> >> +++ b/lib/iommu-helper.c
>> >> @@ -19,7 +19,7 @@ again:
>> >> =A0 =A0 =A0 index =3D (index + align_mask) & ~align_mask;
>> >>
>> >> =A0 =A0 =A0 end =3D index + nr;
>> >> - =A0 =A0 if (end >=3D size)
>> >> + =A0 =A0 if (end > size)
>> >
>> > I think that this is intentional; the last byte of the limit doesn't
>> > work.
>>
>> It looks ok to me. Without above change, find_next_zero_area cannot
>> find a 64 bits zeroed area in next sample code.
>
> I meant that we don't want to find such area for IOMMUs (IIRC, it code
> came from POWER IOMMU).

OK, I see.  I think we need the comment about it.

So we cannot replace find_next_zero_area by bitmap_find_next_zero_area
and current -mmotm has the bug introduced by this patch in iommu-helper
and I also introduced the bug in bitmap_find_next_zero_area if
align_mask !=3D 0 in
bitmap-introduce-bitmap_set-bitmap_clear-bitmap_find_next_zero_area-fix.pat=
ch

Andrew, please drop

lib-iommu-helperc-fix-off-by-one-error-in-find_next_zero_area.patch
iommu-helper-simplify-find_next_zero_area.patch
bitmap-introduce-bitmap_set-bitmap_clear-bitmap_find_next_zero_area.patch
bitmap-introduce-bitmap_set-bitmap_clear-bitmap_find_next_zero_area-fix.pat=
ch
iommu-helper-use-bitmap-library.patch
isp1362-hcd-use-bitmap_find_next_zero_area.patch
mlx4-use-bitmap_find_next_zero_area.patch
sparc-use-bitmap_find_next_zero_area.patch
ia64-use-bitmap_find_next_zero_area.patch
genalloc-use-bitmap_find_next_zero_area.patch

I'll overhaul the patchset and retry again.
