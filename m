From: Matt Causey <matt.causey@gmail.com>
Subject: Re: Is via-velocity broken in 2.6.34?
Date: Wed, 8 Sep 2010 08:27:19 -0700
Message-ID: <AANLkTi=kbonQ11mLpkd4EnSr3ch8yDssnjaUsgw_tVw9@mail.gmail.com>
References: <AANLkTinK4VywsJ86jaC8wQjbXjzvP-z44JD3XbZbMM2a@mail.gmail.com>
	<20100907.163331.260082741.davem@davemloft.net>
	<AANLkTin6RcDPFWpG4YBRF4O-8nrsA6e77K=knBA-uyf9@mail.gmail.com>
	<20100907.172434.28821101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:36267 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126Ab0IHP1V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 11:27:21 -0400
In-Reply-To: <20100907.172434.28821101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 7, 2010 at 5:24 PM, David Miller <davem@davemloft.net> wrot=
e:
> From: Matt Causey <matt.causey@gmail.com>
> Date: Tue, 7 Sep 2010 17:13:14 -0700
>
>> So before I posted to the list, I actually dug through looking for
>> recent changes which would be trivial for me to back out. =A0This wa=
s
>> the only one I had found, so I tried it. =A0:-) =A0No luck though...=
same
>> result.
>
> Thanks, please continue reading up on how to bisect this down,
> that will help us figure out what the problem is.
>

Apologies, my troubleshooting was faulty.  In my testing when I was
switching between 2.6.29 / 2.6.34 there was a .config change that I
failed to notice.  In my  2.6.29 config I had all the default
config_pm and acpi options enabled, whereas in the later config I had
them all disabled.

So, the minimum acpi stuff needed for the driver to function is
CONFIG_PM and CONFIG_ACPI.  None of the timer stuff or anything else
appears to be necessary.  If that's the case (others can correct me if
not...) could we patch the Kconfig to look like this:

config VIA_VELOCITY
        tristate "VIA Velocity support"
        depends on PCI && PM && ACPI

since today it's only depending on pci.

If this is the right thing to do I can submit a patch .  Apologies
again for the red herring.  :-)

Cheers,

--
Matt
