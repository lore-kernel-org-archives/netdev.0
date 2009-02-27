From: Gary Thomas <gary@mlbassoc.com>
Subject: Re: Marvell 88E609x switch?
Date: Fri, 27 Feb 2009 08:26:59 -0700
Message-ID: <49A80643.5050208@mlbassoc.com>
References: <49A5B877.8080403@mlbassoc.com> <20090226151107.GN17040@xi.wantstofly.org> <49A6B991.2090703@mlbassoc.com> <20090226155726.GO17040@xi.wantstofly.org> <49A73E00.7050406@mlbassoc.com> <20090227011903.GS17040@xi.wantstofly.org> <49A7DBA2.8060605@mlbassoc.com> <20090227125211.GV17040@xi.wantstofly.org> <49A7E920.2020601@mlbassoc.com> <20090227142548.GA17040@xi.wantstofly.org> <20090227151815.GA7686@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	Andy Fleming <afleming@freescale.com>, netdev@vger.kernel.org,
	Li Yang <leoli@freescale.com>
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 137-67-76-76.skybeam.com ([76.76.67.137]:4592 "EHLO
	mail.chez-thomas.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753522AbZB0P1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 10:27:13 -0500
In-Reply-To: <20090227151815.GA7686@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov wrote:
> On Fri, Feb 27, 2009 at 03:25:48PM +0100, Lennert Buytenhek wrote:
>> On Fri, Feb 27, 2009 at 06:22:40AM -0700, Gary Thomas wrote:
>>
>>>>> However, the network subsystem still can't locate it.  It may be
>>>>> a complication of the OF stuff and how the [gianfar] network
>>>>> device knows what PHY to look at.
>>>>>
>>>>>   starting network interfaces...
>>>>>   24520:01 not found
>>>>>   eth0: Could not attach to PHY
>>>> It's correct that eth0 should not associate with a PHY -- since the
>>>> MAC connects to the switch chip over GMII/RGMII/SGMII, there is no
>>>> PHY involved.
>>> Yes, but it's expecting to be able to talk to the PHYLIB layer
>>> and ask things like speed, duplex, link state, etc.
>>>
>>>> Is the gianfar driver refusing to up the interface without a PHY?
>>>> It shouldn't do that -- IMHO it's perfectly fine to not have a PHY
>>>> on your ethernet MAC.
>>> It seems so, yes.  I tried disabling the PHY connection in the OF
>>> tree and now eth0 doesn't even try to come up :-(
>> gianfar authors/maintainers: is there a way of using gianfar purely
>> as a (R)(G)MII transport, i.e. without it trying to talk to a PHY?
>> Gary is trying to use it to just pass packets to another
>> (R)(G)MII-speaking chip that doesn't have a PHY interface, but gianfar
>> seems to bail out if you don't give it a PHY to talk to.
> 
> You can use fixed-link property in the device tree, and CONFIG_FIXED_PHY
> driver. See arch/powerpc/boot/dts/mpc8349emitx.dts as an example, and
> Documentation/powerpc/dts-bindings/fsl/tsec.txt for the fixed-link's
> fields meaning.
> 

Yes, thanks, that seems to work.  I can at least now get eth0
starting to come up - still problems with the actual switch.

Can you give me some guidance on my question (linuxppc-devel list 2009-02-26)
with subject 'OF -> platform_device'?  This is needed in order to
use this switch and the DSA layer.

Thanks

-- 
------------------------------------------------------------
Gary Thomas                 |  Consulting for the
MLB Associates              |    Embedded world
------------------------------------------------------------
