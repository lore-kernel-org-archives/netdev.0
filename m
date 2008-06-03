From: Scott Wood <scottwood@freescale.com>
Subject: Re: [RFC] Make board force selection of PHYLIB
Date: Tue, 03 Jun 2008 10:36:10 -0500
Message-ID: <484564EA.8050706@freescale.com>
References: <Pine.LNX.4.64.0806021019540.22439@blarg.am.freescale.net> <484419EE.5040503@garzik.org> <1E4EB64C-0618-497E-AABC-74EB7D74B97F@kernel.crashing.org> <48442239.7090906@garzik.org> <BF15FEBB-4876-4B16-915B-1D21BF989DA8@kernel.crashing.org> <83820D83-487C-4586-9867-F4226A87A276@freescale.com> <48445851.4090105@garzik.org> <095F258F-72DD-4F27-A457-A57D9FAA1E76@kernel.crashing.org> <48448020.5020407@freescale.com> <Pine.LNX.4.64.0806030945540.21537@blarg.am.freescale.net> <48455EEA.3040909@freescale.com> <57B740A4-A3E0-4D93-A5D9-77B14C6E9E92@kernel.crashing.org> <484560C0.2080607@freescale.com> <F70B6328-5DF2-4CCC-9AAF-DD49BDA267A5@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, adrian.bunk@movial.fi
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:50657 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262AbYFCPgV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 11:36:21 -0400
In-Reply-To: <F70B6328-5DF2-4CCC-9AAF-DD49BDA267A5@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
> On Jun 3, 2008, at 10:18 AM, Scott Wood wrote:
>> Kumar Gala wrote:
>>> On Jun 3, 2008, at 10:10 AM, Scott Wood wrote:
>>>> I'd rather avoid adding another case where the kernel needs to know 
>>>> what modules are being built, though, especially if the result of 
>>>> changing the .config and building modules is a mysterious runtime 
>>>> failure (due to a missing platform fixup) rather than compile- or 
>>>> insertion-time.
>>> I don't follow what you are getting at here.  Is this something more 
>>> than #ifdef PHYLIB in the platform code?
>>
>> If you just #ifdef PHYLIB, then things will break if the user does this:
>> make config, GIANFAR=PHYLIB=n
>> make zImage
>> make config, GIANFAR=PHYLIB=m
>> make modules
>>
>> And the cause of the failure will not be something that obviously 
>> points to a build problem, such as unresolved symbols.
> 
> what you are suggesting will not break with my patch.

Yes, it will -- note the absence of a "make zImage" after the second 
make config.

> The second case will for PHYLIB=y w/the select.

And that will only make a difference if you rebuild the kernel itself 
after enabling the module.

-Scott

