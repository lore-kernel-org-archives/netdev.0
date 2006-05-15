From: Jason Lunz <lunz@falooley.org>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 15:27:54 +0000 (UTC)
Message-ID: <e4a6lq$g5v$1@sea.gmane.org>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:27554 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1750976AbWEOP2X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 11:28:23 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1FfezJ-0005WA-Hd
	for netdev@vger.kernel.org; Mon, 15 May 2006 17:28:01 +0200
Received: from jameson.reflexsecurity.com ([72.54.64.66])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 15 May 2006 17:28:01 +0200
Received: from lunz by jameson.reflexsecurity.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 15 May 2006 17:28:01 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

mwallis@serialmonkey.com said:
> Some people are saying that instead of throwing and ACPI event we should be
> either use hotplug or internally just disable the radio and somehow inform
> the dscape stack that the radio has been disabled.
>
> What are peoples thoughts here, should we 
>
> A. be handling this within our drivers and doing "what the user expects" and
> disabling the hardware radio, or 

On my HP laptop with bcm43xx wireless, the button disables the radio in
HARDWARE, and afaict the driver has no idea about it. The driver notices
that it's not connected and happily starts scanning again, unaware that
anything is wrong.

This is actually quite nice for testing roaming setups. You can "roam"
in and out of range by toggling the button.

The other laptop in the house has a physical _switch_, which implies
that it too cuts off the radio in hardware (though I haven't
investigated this, so I'm only speculating).

So if there's any desire for consistency of wireless button support,
then I think the software-controlled ones should always shut off the
radio, and optionally inform userspace or the wireless stack using some
event mechanism.

What is the purpose of these switches anyway? Power saving? Or is it for
situations like an airplane or hospital where you want to be sure your
wireless won't cause any interference? If the latter, than that also
argues for always shutting off the radio immediately.

Jason

