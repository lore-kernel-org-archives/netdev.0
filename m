From: Julien Grall <julien.grall@citrix.com>
Subject: Re: [PATCH 4/8] xen: Use the correctly the Xen memory terminologies
Date: Wed, 29 Jul 2015 15:23:03 +0100
Message-ID: <55B8E1C7.6070608@citrix.com>
References: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
 <1438095769-2560-5-git-send-email-julien.grall@citrix.com>
 <55B7D40B.5080903@oracle.com> <55B8B846.2060103@citrix.com>
 <55B8DFD7.6070107@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-fbdev@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	"Jiri Slaby" <jslaby@suse.com>, <stefano.stabellini@eu.citrix.com>,
	Russell King <linux@arm.linux.org.uk>,
	<linux-scsi@vger.kernel.org>, <x86@kernel.org>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	<linux-input@vger.kernel.org>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	<ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	<linux-arm-kernel@lists.infradead.org>,
	Juergen Gross <jgross@suse.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	<linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	=?win
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55B8DFD7.6070107@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29/07/15 15:14, Boris Ostrovsky wrote:
>> static inline unsigned long pfn_to_gfn(unsigned long pfn)
>> {
>>     if (xen_feature(XENFEAT_autotranslated_physmap))
>>         return pfn;
>>     else
>>         return pfn_to_mfn(pfn);
>> }
> 
> 
> But you'd still say 'op.arg1.mfn = pfn_to_gfn(pfn);' in xen_do_pin()
> i.e. assign GFN to MFN, right? That's what I was referring to.

Well no. I would use op.arg1.mfn = pfn_to_mfn(pfn) given that the code,
if I'm right, is only executed for PV.

mfn = pfn_to_gfn(...) was valid too because on PV is always an MFN. The
suggestion of pfn_to_mfn was just for more readability,

> (In general, I am not sure a guest should ever use 'mfn' as it is purely
> a hypervisor construct. Including p2m, which I think should really be
> p2g as this is what we use to figure out what to stick into page tables)

I think avoid to use mfn in the hypervisor interface is out-of-scope for
this series. If we ever want to modify the Xen API in Linux, we should
do in sync with Xen to avoid inconsistency on naming.

Anyway, the oddity of mfn = pfn_to_gfn(...) is mostly contained in the
x86 specific code. I don't mind to either add pfn_to_mfn and use it or
add a comment /* PV-specific so mfn == gfn */ for every use of mfn =
pfn_to_gfn(...).

Regards,

-- 
Julien Grall
