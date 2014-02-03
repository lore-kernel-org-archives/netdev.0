From: Stefano Stabellini <stefano.stabellini@eu.citrix.com>
Subject: Re: [Xen-devel] [PATCH v6] xen/grant-table: Avoid m2p_override during
 mapping
Date: Mon, 3 Feb 2014 11:13:35 +0000
Message-ID: <alpine.DEB.2.02.1402031103070.4373@kaball.uk.xensource.com>
References: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com> <alpine.DEB.2.02.1401232333280.15917@kaball.uk.xensource.com> <52EE1E26.2040308@linaro.org> <52EE93F0.1020508@citrix.com> <52EF7618.7030402@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="1342847746-1122221688-1391425897=:4373"
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Julien Grall <julien.grall@linaro.org>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	<jonathan.davies@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:20110 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752415AbaBCLNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Feb 2014 06:13:45 -0500
In-Reply-To: <52EF7618.7030402@citrix.com>
Content-ID: <alpine.DEB.2.02.1402031111440.4373@kaball.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--1342847746-1122221688-1391425897=:4373
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: QUOTED-PRINTABLE
Content-ID: <alpine.DEB.2.02.1402031111441.4373@kaball.uk.xensource.com>

On Mon, 3 Feb 2014, David Vrabel wrote:
> On 02/02/14 18:52, Zoltan Kiss wrote:
> > On 02/02/14 11:29, Julien Grall wrote:
> >> Hello,
> >>
> >> This patch is breaking Linux compilation on ARM:
> >>
> >> drivers/xen/grant-table.c: In function =E2=80=98__gnttab_map_refs=E2=
=80=99:
> >> drivers/xen/grant-table.c:989:3: error: implicit declaration of
> >> function =E2=80=98FOREIGN_FRAME=E2=80=99 [-Werror=3Dimplicit-function-=
declaration]
> >>     if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn)))) {
> >>     ^
> >> drivers/xen/grant-table.c: In function =E2=80=98__gnttab_unmap_refs=E2=
=80=99:
> >> drivers/xen/grant-table.c:1054:3: error: implicit declaration of
> >> function =E2=80=98get_phys_to_machine=E2=80=99 [-Werror=3Dimplicit-fun=
ction-declaration]
> >>     mfn =3D get_phys_to_machine(pfn);
> >>     ^
> >> drivers/xen/grant-table.c:1055:43: error: =E2=80=98FOREIGN_FRAME_BIT=
=E2=80=99
> >> undeclared (first use in this function)
> >>     if (mfn =3D=3D INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT)) {
> >>                                             ^
> >> drivers/xen/grant-table.c:1055:43: note: each undeclared identifier is
> >> reported only once for each function it appears in
> >> drivers/xen/grant-table.c:1068:9: error: too many arguments to
> >> function =E2=80=98m2p_remove_override=E2=80=99
> >>           mfn);
> >>           ^
> >> In file included from include/xen/page.h:4:0,
> >>                   from drivers/xen/grant-table.c:48:
> >> /local/home/julien/works/midway/linux/arch/arm/include/asm/xen/page.h:=
106:19:
> >> note: declared here
> >>   static inline int m2p_remove_override(struct page *page, bool
> >> clear_pte)
> >>                     ^
> >> cc1: some warnings being treated as errors
> >=20
> > Hi,
> >=20
> > That's bad indeed. I think the best solution is to put those parts
> > behind an #ifdef x86. The ones moved from x86/p2m.c to grant-table.c.
> > David, Stefano, what do you think?
>=20
> I don't think we want (more) #ifdef CONFIG_X86 in grant-table.c and the
> arch-specific bits will have to factored out into their own functions
> with suitable stubs provided for ARM.

We certainly don't want more ifdefs like that.


> But, this patch went in late and it's clearly not ready. So I think it
> should be reverted and we should aim to get it sorted out for 3.15.
>=20
> Konrad/Stefano (if you agree) please revert
> 08ece5bb2312b4510b161a6ef6682f37f4eac8a1 and send a pull request.

Unfortunately I have to agree: fixing the prototype of
m2p_remove_override and replacing get_phys_to_machine with pfn_to_mfn is
easy.
However FOREIGN_FRAME is an x86-ism and I don't feel confortable with
adding yet another #define under arch/arm/xen just to deal with x86
stuff that spill on common code.

Sorry for not spotting this earlier.


> Konrad, I also think you should look at adding an ARM build to your test
> system (I thought you had this already).

Let's talk about how to set it up offline.
--1342847746-1122221688-1391425897=:4373--
