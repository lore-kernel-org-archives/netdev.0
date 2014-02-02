From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH v6] xen/grant-table: Avoid m2p_override during
 mapping
Date: Sun, 2 Feb 2014 19:52:32 +0100
Message-ID: <52EE93F0.1020508@citrix.com>
References: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com> <alpine.DEB.2.02.1401232333280.15917@kaball.uk.xensource.com> <52EE1E26.2040308@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jonathan.davies@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	David Vrabel <david.vrabel@citrix.com>
To: Julien Grall <julien.grall@linaro.org>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EE1E26.2040308@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/02/14 11:29, Julien Grall wrote:
> Hello,
>
> This patch is breaking Linux compilation on ARM:
>
> drivers/xen/grant-table.c: In function =91__gnttab_map_refs=92:
> drivers/xen/grant-table.c:989:3: error: implicit declaration of funct=
ion =91FOREIGN_FRAME=92 [-Werror=3Dimplicit-function-declaration]
>     if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn)))) {
>     ^
> drivers/xen/grant-table.c: In function =91__gnttab_unmap_refs=92:
> drivers/xen/grant-table.c:1054:3: error: implicit declaration of func=
tion =91get_phys_to_machine=92 [-Werror=3Dimplicit-function-declaration=
]
>     mfn =3D get_phys_to_machine(pfn);
>     ^
> drivers/xen/grant-table.c:1055:43: error: =91FOREIGN_FRAME_BIT=92 und=
eclared (first use in this function)
>     if (mfn =3D=3D INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT)) {
>                                             ^
> drivers/xen/grant-table.c:1055:43: note: each undeclared identifier i=
s reported only once for each function it appears in
> drivers/xen/grant-table.c:1068:9: error: too many arguments to functi=
on =91m2p_remove_override=92
>           mfn);
>           ^
> In file included from include/xen/page.h:4:0,
>                   from drivers/xen/grant-table.c:48:
> /local/home/julien/works/midway/linux/arch/arm/include/asm/xen/page.h=
:106:19: note: declared here
>   static inline int m2p_remove_override(struct page *page, bool clear=
_pte)
>                     ^
> cc1: some warnings being treated as errors

Hi,

That's bad indeed. I think the best solution is to put those parts=20
behind an #ifdef x86. The ones moved from x86/p2m.c to grant-table.c.=20
David, Stefano, what do you think?

Zoli
