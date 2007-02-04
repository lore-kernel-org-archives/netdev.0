From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: 2.6.20-rc7: known regressions (v2) (part 1)
Date: Sat, 03 Feb 2007 22:12:43 -0700
Message-ID: <m1ireizet0.fsf@ebiederm.dsl.xmission.com>
References: <Pine.LNX.4.64.0701302019530.11095@woody.linux-foundation.org>
	<20070203004447.GJ3754@stusta.de> <45C42669.2010105@intel.com>
	<m1k5yz3cxy.fsf@ebiederm.dsl.xmission.com>
	<089b01c747be$0ca22620$84163e05@kroptech.com>
	<45C4F3F1.6060500@intel.com>
	<m1ejp70wu0.fsf@ebiederm.dsl.xmission.com>
	<098001c747e9$d8931b60$84163e05@kroptech.com>
	<m1ps8qzpte.fsf@ebiederm.dsl.xmission.com>
	<09ba01c74817$1ae12980$84163e05@kroptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Auke Kok" <auke-jan.h.kok@intel.com>,
	"Adrian Bunk" <bunk@stusta.de>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	<jgarzik@pobox.com>, <alan@lxorguk.ukuu.org.uk>,
	"Allen Parker" <parker@isohunt.com>, <jesse.brandeburg@intel.com>,
	<gregkh@suse.de>, <linux-pci@atrey.karlin.mff.cuni.cz>,
	<netdev@vger.kernel.org>
To: "Adam Kropelin" <akropel1@rochester.rr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:47626 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085AbXBDFOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 00:14:07 -0500
In-Reply-To: <09ba01c74817$1ae12980$84163e05@kroptech.com> (Adam Kropelin's
	message of "Sat, 3 Feb 2007 23:44:07 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Adam Kropelin" <akropel1@rochester.rr.com> writes:

> Naive question... Can the pci layer (or e1000) detect that MSI is not enabled in
> the hardware and avoid using it in that case? With the number of MSI problems
> showing up it seems risky to assume it's usable on any given platform without
> some sort of sanity check.
>

Yes, that is what we should do.  Start with the assumption MSI doesn't work
and enable it when we detect the hardware is setup properly.

Thing is that is going to take a little bit of work, and a little bit of
thinking on how to structure it properly.  So in real time it is going
to be a couple of weeks before the code to do that is ready.

Right now the model is that piecemeal we put in the code to
conditionally turn off chipsets that are known to have problems.
Which for building a reliable system when MSI isn't mandatory for
operation seems backwards.

Probably in addition we should have a warning such as:
"Found devices supporting MSI and but chipset is unknown".

Eric
