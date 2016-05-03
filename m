From: Amr Bekhit <amrbekhit@gmail.com>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Tue, 3 May 2016 15:38:17 +0100
Message-ID: <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
References: <CAOLz05qgn2-9Qxm1cR7mXa67GAwD2SGbMnbeeEBrYeSPsBexuw@mail.gmail.com>
 <5717C45F.30205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, andrew@lunn.ch
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34127 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269AbcECOii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 10:38:38 -0400
Received: by mail-wm0-f54.google.com with SMTP id v200so28973335wmv.1
        for <netdev@vger.kernel.org>; Tue, 03 May 2016 07:38:37 -0700 (PDT)
In-Reply-To: <5717C45F.30205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Thanks for your response. I had look through the bootup messages on my
Linux board and saw the following:

[    5.398437] libphy: MACB_mii_bus: probed
[    5.484375] macb f802c000.ethernet eth0: Cadence MACB rev
0x0001010c at 0xf802c000 irq 39 (70:b3:d5:ba:b8:90)
[    5.492187] macb f802c000.ethernet eth0: attached PHY driver
[Davicom DM9161A] (mii_bus:phy_addr=f802c000.etherne:00, irq=-1)

So it appears that the DM9161A driver is already being loaded for the
DM9162. I checked through the datasheet for the DM9162 and I confirmed
that the OUI was indeed the same as the one for the DM9161A. I can
only imagine that the company would do that because they are
compatible with each other. They are pin to pin compatible as well. As
you said, it's likely the existing PHY driver is compatible.

The reason why I suspected the PHY is because I have an embedded
system where I cannot seem to get any ethernet packets out from (see:
http://www.linuxquestions.org/questions/linux-embedded-and-single-board-computer-78/no-response-to-dhcp-discover-packets-sent-on-eth0-4175577259/).
One thing that was suggested to me was whether there was a problem
with the link between the MAC and PHY, which is what lead me to look
at the PHY drivers in Linux and hence this question.

Any ideas as to why I can't get any packets out? Is there a way for me
to test whether there is an issue between the MAC and PHY?

Thanks,

Amr


On 20 April 2016 at 19:03, Florian Fainelli <f.fainelli@gmail.com> wrote:
> Hi,
>
> On 20/04/16 08:21, Amr Bekhit wrote:
>> Hello,
>>
>> I'm using an embedded Linux board based on an AT91SAM9X25 that uses the
>> Davicom DM9162IEP PHY chip. I'm struggling to get packets out on the
>> wire and I'm suspecting that I might have an issue between the AT91 MAC
>> and the PHY chip. I've looked through the kernel config options and the
>> kernel already has compiled-in support for the Davicom PHYs, however I
>> noticed that according to the help text, only the dm9161e and dm9131
>> chips are supported, which may indicate why my ethernet isn't working. I
>> was wondering whether the DM9162 is backwards compatible with the
>> existing driver? I'm currently using the mainline kernel 4.3. (p.s. I
>> know the hardware works fine since I have no problem transferring files
>> using tftp via u-boot).
>
> Well, u-boot is a very simplistic networking stack, there could be tons
> of issues that get under the radar because it cannot report them
> properly, but let's assume it works so you have something to compare
> against.
>
> The DM9162 should be very similar to the DM9161, so the first thing
> might be trying to add the PHY ID (32-bits OUI) to the matching table in
> drivers/net/phy/davicom.c, and make it configure the PHY through
> dm9161_config_init() since that looks at the PHY interface (MII, RMII
> etc.) and does a bit of configuration here.
>
> Right now, chances are that you are running with the Generic PHY driver
> which has no clue about Davicom specific programming (if any). There
> could also be board-level fixups required (adjusting trace lengths, if
> you are using a RGMII interface for instance), etc.
> --
> Florian
