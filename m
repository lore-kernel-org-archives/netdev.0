From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: e100 firmware in 2.6.29-rc7?
Date: Mon, 16 Mar 2009 19:25:40 +0000
Message-ID: <1237231540.3106.9.camel@achroite>
References: <49BABF1F.9080909@candelatech.com>
	 <alpine.WNT.2.00.0903161143180.5116@jbrandeb-desk1.amr.corp.intel.com>
	 <49BEA4E6.1000206@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	NetDev <netdev@vger.kernel.org>, dwmw2@infradead.org,
	e1000-devel@lists.sourceforge.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:48161 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755030AbZCPTZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 15:25:51 -0400
In-Reply-To: <49BEA4E6.1000206@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-03-16 at 12:13 -0700, Ben Greear wrote:
> Brandeburg, Jesse wrote:
> > On Fri, 13 Mar 2009, Ben Greear wrote:
> >> I have selected build-firmware-into-kernel
> >> but it seems e100 is still unhappy in 2.6.29-rc7.
> >>
> >> e100 0000:02:01.0: firmware: requesting e100/d102e_ucode.bin
> >> e100: eth4: e100_request_firmware: Failed to load firmware "e100/d102e_ucode.bin": -2
> > 
> > can you post anything extra about your config? arch? full dmesg? full 
> > .config?
> > 
> > There have been several other reports of this but setting 
> > CONFIG_FIRMWARE_IN_KERNEL=y seems to fix them in general.
> > 
> > also please post lspci -vvv -s 2:1.0, after failing to load.  I'm curious 
> > if the device might be in D3 still.
> > 
> > you can likely just get working by commenting out the firmware load for 
> > e100.  It may or may not re-enable a hardware bug depending upon the 
> > hardware you have.
> 
> We got it working by copying firmware from another system (FC8) that had
> it in /lib/firmware.
> 
> Just retested with -rc8 from Friday, and it is repeatable.
> 
> The config & dmesg is attached.  Some of the options are for patches we've
> added, and we even have a small patch in the e100 (but have had it there
> for years, so probably un-related to this).  Still, I will not complain
> if you decide to ignore the report.
[...]

Your config has CONFIG_E100=m, but CONFIG_FIRMWARE_IN_KERNEL only
applies to firmware used by non-modular drivers.  The assumption is that
once userland is capable of loading modules it is also capable of
loading firmware.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

