From: Mike Rapoport <mike@compulab.co.il>
Subject: Re: smsc911x suspend/resume
Date: Mon, 08 Feb 2010 15:55:59 +0200
Message-ID: <4B7017EF.4080909@compulab.co.il>
References: <OFE2B2FE18.A8D1D506-ON802576C4.003FCA39-802576C4.0040B683@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@caiaq.de>,
	LAKML <linux-arm-kernel@lists.infradead.org>,
	netdev@vger.kernel.org, Ian.Saturley@smsc.com,
	Vlad.Lyalikov@smsc.com, davem@davemloft.net
To: Steve.Glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from compulab.co.il ([67.18.134.219]:33621 "EHLO compulab.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792Ab0BHN5A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 08:57:00 -0500
In-Reply-To: <OFE2B2FE18.A8D1D506-ON802576C4.003FCA39-802576C4.0040B683@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve.Glendinning@smsc.com wrote:
> Hi Mike,
> 
>>>> I'm trying to make suspend/resume work on OMAP3-based system and I'm
>>>> encountering issues with resume of SMSC 9220 chip.
>>>> After resume the interface is unusable unless I do 'ifconfig eth0 
> down'
>>>> and 'ifconfig eth0 up'.
>>>> I would expect that 'ping <some host>' would work right after resume
>>>> without need to bring the interface down and up, but probably I miss
>>>> something.
>>>> Any help would be appreciated.
>>> What happens to your supply voltages when going to suspend? When I
>>> implemented the code for the smsc driver, I could only test scenarios
>>> where AVDD remains stable during suspend. So the driver might need 
> some
>>> tweaks if that assumption is not true in your case. The SMSC datasheet
>>> is quite comprehensive about this topic IIRC.
>> By AVDD you mean VDD33A?
>> Anyway, I have all the supplies except VDDVARIO shut down...
>> And the datasheet is indeed comprehensively describes chip power states
>> but I haven't found there anything about supplies required to stay on
>> during suspend...
> 
> I don't have the code in front of me (I'm travelling today) but IIRC
> the driver doesn't place the LAN9220 in a specific power saving state,
> so as far as the LAN9220 is concerned it's not actually suspended.
> 
> It's hard to do this in a "generic" way: some people expect their link
> to stay up during suspend, some want suspend to completely power down
> the ethernet chip, and some want to use one of several WoL modes. 

Indeed a "generic" implementation may be tough task... Probably we can
add some platform_data flags for suspend modes and use them to decide
what low power mode should be selected?

> David: What's the "done thing" here for similar non-pci drivers?
> Obviously "doesn't work after suspend" isn't the intended behaviour, so
> there's definitely room for improvement!
> 
>>> Also have a look at the Raumfeld device patches which use exactly this
>>> chip and which can suspend and resume just fine. You'll need to check
>>> out Eric's devel branch for that.
> 
> Daniel: I haven't seen this, do you have a location for the git tree?
> 
> Thanks,
> Steve


-- 
Sincerely yours,
Mike.
