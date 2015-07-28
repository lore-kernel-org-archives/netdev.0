From: Andrew Cooper <andrew.cooper3@citrix.com>
Subject: Re: [Xen-devel] [PATCH 0/8] Use correctly the Xen memory terminologies
 in Linux
Date: Tue, 28 Jul 2015 22:12:21 +0100
Message-ID: <55B7F035.6010201@citrix.com>
References: <1438095769-2560-1-git-send-email-julien.grall@citrix.com>
 <55B7EECD.8050605@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-fbdev@vger.kernel.org>, <x86@kernel.org>,
	<netdev@vger.kernel.org>, Jiri Slaby <jslaby@suse.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"Russell King" <linux@arm.linux.org.uk>,
	<linux-scsi@vger.kernel.org>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>,
	<stefano.stabellini@eu.citrix.com>, Ingo Molnar <mingo@redhat.com>,
	<linux-input@vger.kernel.org>,
	"Jean-Christophe Plagniol-Villard" <plagnioj@jcrosoft.com>,
	<ian.campbell@citrix.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	<linux-arm-kernel@lists.infradead.org>,
	"Juergen Gross" <jgross@suse.com>, Wei Liu <wei.liu2@citrix.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	<linux-kernel@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	<linux-api@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	=?windows-1
To: "H. Peter Anvin" <hpa@zytor.com>,
	Julien Grall <julien.grall@citrix.com>,
	<xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:23022 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752774AbbG1VMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 17:12:35 -0400
In-Reply-To: <55B7EECD.8050605@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/07/15 22:06, H. Peter Anvin wrote:
> On 07/28/2015 08:02 AM, Julien Grall wrote:
>> Hi all,
>>
>> This patch series aims to use the memory terminologies described in
>> include/linux/mm.h [1] for Linux xen code.
>>
>> Linux is using mistakenly MFN when GFN is meant, I suspect this is because the
>> first support of Xen was for PV. This has brought some misimplementation
>> of memory helpers on ARM and make the developper confused about the expected
>> behavior.
>>
>> For instance, with pfn_to_mfn, we expect to get a MFN based on the name.
>> Although, if we look at the implementation on x86, it's returning a GFN.
>> Most of the callers are also using it this way.
>>
>> The first 2 patches of this series is ARM related in order to remove
>> PV specific helpers which should not be used and fixing the implementation of
>> pfn_to_mfn.
>>
>> The rest of the series is here rename most of the usage in the common code
>> of MFN to GFN. I also took the opportunity to replace most of the call to
>> pfn_to_gfn in the common code by page_to_gfn avoid construction such
>> as pfn_to_gfn(page_to_pfn(...).
>>
>> Note the one xen-blkfront will be dropped by 64K series [2], I can include it
>> if necessary.
>>
> Can we actually get some documentation for Xen before starting to change
> names around?

http://xenbits.xen.org/gitweb/?p=xen.git;a=commitdiff;h=e758ed14f390342513405dd766e874934573e6cb

~Andrew
