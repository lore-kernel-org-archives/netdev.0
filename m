From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Revert sky2 to 0.13a
Date: Mon, 27 Feb 2006 13:38:11 -0500
Message-ID: <44034713.5080102@pobox.com>
References: <4400FC28.1060705@gmx.net> <200602270003.46353.woho@woho.de>	 <20060227080042.0cf3f05d@localhost.localdomain>	 <200602271738.38675.woho@woho.de>	 <20060227091837.3c214435@localhost.localdomain> <1141064841.23375.36.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, woho@woho.de,
	Carl-Daniel Hailfinger <c-d.hailfinger.devel.2006@gmx.net>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	Pavel Volkovitskiy <int@mtx.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751512AbWB0Si1@vger.kernel.org>
To: pomac@vapor.com
In-Reply-To: <1141064841.23375.36.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ian Kumlien wrote:
> On Mon, 2006-02-27 at 09:18 -0800, Stephen Hemminger wrote:
> 
>>On Mon, 27 Feb 2006 17:38:38 +0100
>>Wolfgang Hoffmann <woho@woho.de> wrote:
>>
>>>On Monday 27 February 2006 17:00, Stephen Hemminger wrote:
>>>2.6.16-rc5 with disable_msi=1 works for me, no hangs seen so far. I rsynced 80 
>>>GB of data, thats about 5-10 times more than I typically need to reproduce a 
>>>hang, so it seems to be solid. For the record: 2.6.16-rc5 with disable_msi=0 
>>>does hang.
>>>
>>>I have not seen the memory trashing others reported, with no version I tested 
>>>so far. Maybe my scenario is not likely to trigger this, so I can't tell.
>>>
>>>Unless a fix for msi is at hand, may I suggest for 2.6.16 to revert the msi 
>>>commit or switch the default to disable_msi=1?
>>>
>>>I've updated bugzilla #6084 accordingly.
>>
>>Okay, then what I need is lspci -v of all systems that have the problem, I'll make
>>a blacklist (or update PCI quirks). I suspect that MSI doesn't work for any devices
>>on these systems, or MSI changes the timing enough to expose existing races.
> 
> 
> Am i just tired from trying to make XSLT to do something unnatural or is
> there something odd going on in msi.c?
> 
> static void msi_set_mask_bit(unsigned int vector, int flag)
> {
>         struct msi_desc *entry;
> 
>         entry = (struct msi_desc *)msi_desc[vector];
>         if (!entry || !entry->dev || !entry->mask_base)
>                 return;
>         switch (entry->msi_attrib.type) {
>         case PCI_CAP_ID_MSI:
>         {
>                 int             pos;		<==
>                 u32             mask_bits;
> 
>                 pos = (long)entry->mask_base;	<==
> ...

Just from the casting it seems a bit bogus, yes...

	Jeff
