From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v6] xen/grant-table: Avoid m2p_override
 during mapping
Date: Mon, 3 Feb 2014 06:50:40 -0500
Message-ID: <20140203115040.GB3400@phenom.dumpdata.com>
References: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com>
 <alpine.DEB.2.02.1401232333280.15917@kaball.uk.xensource.com>
 <52EE1E26.2040308@linaro.org>
 <52EE93F0.1020508@citrix.com>
 <52EF7618.7030402@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>, jonathan.davies@citrix.com,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	netdev@vger.kernel.org, Julien Grall <julien.grall@linaro.org>,
	linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52EF7618.7030402@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 03, 2014 at 10:57:28AM +0000, David Vrabel wrote:
> On 02/02/14 18:52, Zoltan Kiss wrote:
> > On 02/02/14 11:29, Julien Grall wrote:
> >> Hello,
> >>
> >> This patch is breaking Linux compilation on ARM:
> >>
> >> drivers/xen/grant-table.c: In function =E2=80=98__gnttab_map_refs=E2=
=80=99:
> >> drivers/xen/grant-table.c:989:3: error: implicit declaration of
> >> function =E2=80=98FOREIGN_FRAME=E2=80=99 [-Werror=3Dimplicit-funct=
ion-declaration]
> >>     if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn)))) {
> >>     ^
> >> drivers/xen/grant-table.c: In function =E2=80=98__gnttab_unmap_ref=
s=E2=80=99:
> >> drivers/xen/grant-table.c:1054:3: error: implicit declaration of
> >> function =E2=80=98get_phys_to_machine=E2=80=99 [-Werror=3Dimplicit=
-function-declaration]
> >>     mfn =3D get_phys_to_machine(pfn);
> >>     ^
> >> drivers/xen/grant-table.c:1055:43: error: =E2=80=98FOREIGN_FRAME_B=
IT=E2=80=99
> >> undeclared (first use in this function)
> >>     if (mfn =3D=3D INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT)=
) {
> >>                                             ^
> >> drivers/xen/grant-table.c:1055:43: note: each undeclared identifie=
r is
> >> reported only once for each function it appears in
> >> drivers/xen/grant-table.c:1068:9: error: too many arguments to
> >> function =E2=80=98m2p_remove_override=E2=80=99
> >>           mfn);
> >>           ^
> >> In file included from include/xen/page.h:4:0,
> >>                   from drivers/xen/grant-table.c:48:
> >> /local/home/julien/works/midway/linux/arch/arm/include/asm/xen/pag=
e.h:106:19:
> >> note: declared here
> >>   static inline int m2p_remove_override(struct page *page, bool
> >> clear_pte)
> >>                     ^
> >> cc1: some warnings being treated as errors
> >=20
> > Hi,
> >=20
> > That's bad indeed. I think the best solution is to put those parts
> > behind an #ifdef x86. The ones moved from x86/p2m.c to grant-table.=
c.
> > David, Stefano, what do you think?
>=20
> I don't think we want (more) #ifdef CONFIG_X86 in grant-table.c and t=
he
> arch-specific bits will have to factored out into their own functions
> with suitable stubs provided for ARM.
>=20
> But, this patch went in late and it's clearly not ready. So I think i=
t
> should be reverted and we should aim to get it sorted out for 3.15.
>=20
> Konrad/Stefano (if you agree) please revert
> 08ece5bb2312b4510b161a6ef6682f37f4eac8a1 and send a pull request.

OK, queued up. I also put on the xen/cr4 patch on the queue - just sent
an email with it.

>=20
> Konrad, I also think you should look at adding an ARM build to your t=
est
> system (I thought you had this already).
>=20
> David
>=20
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
