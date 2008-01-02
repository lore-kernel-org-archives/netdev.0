From: Adrian Bunk <bunk@kernel.org>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Thu, 3 Jan 2008 01:42:09 +0200
Message-ID: <20080102234209.GA10831@does.not.exist>
References: <477BFC71.7090002@coderworld.net> <20080102214843.GA19224@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Richard Jonsson <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:34968 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756763AbYABXm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jan 2008 18:42:28 -0500
Content-Disposition: inline
In-Reply-To: <20080102214843.GA19224@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ original bug report: http://lkml.org/lkml/2008/1/2/253 ]

On Wed, Jan 02, 2008 at 10:48:43PM +0100, Andreas Mohr wrote:
> Hi,
> 
> On Wed, Jan 02, 2008 at 10:04:49PM +0100, Richard Jonsson wrote:
> > Bugreport regarding forcedeth driver.
> >
> > When returning from suspend-to-RAM the MAC-address byteorder is reversed. 
> > After another suspend-resume cycle the MAC-address is again correct. This 
> > brings a great deal of pain since the NIC is assigned a random MAC-address 
> > when it is detected as invalid.
> >
> > I cannot say if this issue appeared recently or if it's been in the kernel 
> > for a while, as I've been using wireless until recently.
> >
> > I read somewhere on lkml that the mac is read from the device, then 
> > reversed and finally written back to the device. Can it be that it is read 
> > again on resume and reversed, and then again written to the device? This 
> > would explain why it's ok every other resume cycle.
> 
> Uh, Use The Source, Luke?
> 
> But no, I think it's simply driver dainbreadness, not a matter of
> complicated writing and reading back in reversed order.
> 
> drivers/net/forcedeth.c has a nice DEV_HAS_CORRECT_MACADDR flag which is
> being enabled for certain cards (those which need this) and disabled for others.
> 
> The nv_probe() function then nicely obeys this flag by reversing the
> address if needed, _however_ there's another function, nv_copy_mac_to_hw(),
> which does _NOT_ obey it and simply copies the _raw_ netdev dev_addr
> to the card register (NvRegMacAddrA etc.).
> 
> I don't know, this all looks a bit dirty to me, MAC reading/writing
> should have been implemented in a more central way, then those people
> wouldn't have confused heaven and hell with MAC address fiddling.
> 
> And yeah, this certainly looks like a bug that should be fixed ASAP,
> unless my short analysis somehow happened to be wrong.
> (I could probably fix it, but then the forcedeth people
> most likely know better how they would like to see it implemented)
> 
> Thank you for your report!
> 
> Now the only thing remaining would be: is there a specific way to
> contact forcedeth-related people? I didn't find anything within a short
> search.

Cc's added.

> Andreas Mohr

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

