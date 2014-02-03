From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH v6] xen/grant-table: Avoid m2p_override during
 mapping
Date: Mon, 3 Feb 2014 10:57:28 +0000
Message-ID: <52EF7618.7030402@citrix.com>
References: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com>	<alpine.DEB.2.02.1401232333280.15917@kaball.uk.xensource.com>	<52EE1E26.2040308@linaro.org> <52EE93F0.1020508@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julien Grall <julien.grall@linaro.org>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	<jonathan.davies@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EE93F0.1020508@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/02/14 18:52, Zoltan Kiss wrote:
> On 02/02/14 11:29, Julien Grall wrote:
>> Hello,
>>
>> This patch is breaking Linux compilation on ARM:
>>
>> drivers/xen/grant-table.c: In function =91__gnttab_map_refs=92:
>> drivers/xen/grant-table.c:989:3: error: implicit declaration of
>> function =91FOREIGN_FRAME=92 [-Werror=3Dimplicit-function-declaratio=
n]
>>     if (unlikely(!set_phys_to_machine(pfn, FOREIGN_FRAME(mfn)))) {
>>     ^
>> drivers/xen/grant-table.c: In function =91__gnttab_unmap_refs=92:
>> drivers/xen/grant-table.c:1054:3: error: implicit declaration of
>> function =91get_phys_to_machine=92 [-Werror=3Dimplicit-function-decl=
aration]
>>     mfn =3D get_phys_to_machine(pfn);
>>     ^
>> drivers/xen/grant-table.c:1055:43: error: =91FOREIGN_FRAME_BIT=92
>> undeclared (first use in this function)
>>     if (mfn =3D=3D INVALID_P2M_ENTRY || !(mfn & FOREIGN_FRAME_BIT)) =
{
>>                                             ^
>> drivers/xen/grant-table.c:1055:43: note: each undeclared identifier =
is
>> reported only once for each function it appears in
>> drivers/xen/grant-table.c:1068:9: error: too many arguments to
>> function =91m2p_remove_override=92
>>           mfn);
>>           ^
>> In file included from include/xen/page.h:4:0,
>>                   from drivers/xen/grant-table.c:48:
>> /local/home/julien/works/midway/linux/arch/arm/include/asm/xen/page.=
h:106:19:
>> note: declared here
>>   static inline int m2p_remove_override(struct page *page, bool
>> clear_pte)
>>                     ^
>> cc1: some warnings being treated as errors
>=20
> Hi,
>=20
> That's bad indeed. I think the best solution is to put those parts
> behind an #ifdef x86. The ones moved from x86/p2m.c to grant-table.c.
> David, Stefano, what do you think?

I don't think we want (more) #ifdef CONFIG_X86 in grant-table.c and the
arch-specific bits will have to factored out into their own functions
with suitable stubs provided for ARM.

But, this patch went in late and it's clearly not ready. So I think it
should be reverted and we should aim to get it sorted out for 3.15.

Konrad/Stefano (if you agree) please revert
08ece5bb2312b4510b161a6ef6682f37f4eac8a1 and send a pull request.

Konrad, I also think you should look at adding an ARM build to your tes=
t
system (I thought you had this already).

David
