From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Thu, 12 Jul 2012 09:22:58 +0200
Message-ID: <CABkLObpRNpcEjFYaUUEjnEWN-8snQZaa27+CCO7pHnR7kPVMUg@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
	<CANEJEGu3iTDYJD+ZpcwgRCZTF8a_bi9kWSuKK4eaHzS1uL+ZxA@mail.gmail.com>
	<CABkLObon+CkLJagu2pX0OBGpNzSn9NfyM353h2BQ68viy2Bq6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>
To: Grant Grundler <grundler@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45896 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab2GLHW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 03:22:58 -0400
Received: by yhmm54 with SMTP id m54so2400394yhm.19
        for <netdev@vger.kernel.org>; Thu, 12 Jul 2012 00:22:58 -0700 (PDT)
In-Reply-To: <CABkLObon+CkLJagu2pX0OBGpNzSn9NfyM353h2BQ68viy2Bq6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Grant,

On Mon, Jul 9, 2012 at 12:22 PM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> Grant,
>
> On Fri, Jul 6, 2012 at 11:20 PM, Grant Grundler <grundler@chromium.org> wrote:
>> On Fri, Jul 6, 2012 at 4:33 AM, Christian Riesch
>> <christian.riesch@omicron.at> wrote:
>>> The Asix AX88172A is a USB 2.0 Ethernet interface that supports both an
>>> internal PHY as well as an external PHY (connected via MII).
>>>
>>> This patch adds a driver for the AX88172A and provides support for
>>> both modes and supports phylib.
>>
>> Christian,
>> In general this looks fine to me...but I wouldn't know about "bus
>> identifier life times" (Ben Hutchings comment).
>>
>> My nit pick is the declaration and of use_embdphy. An alternative
>> coding _suggestion_ below.  I'm not substantially altering the
>> functionality.
>>
>> thanks,
>> grant
>
> [...]
>
>>> +
>>> +struct ax88172a_private {
>>> +       int use_embdphy;
>>
>> Can you move the "int" to the end of the struct?
>> It's cleaner to have fields "natively align". ie pointers should start
>> at 8 byte alignments when compiled for 64-bit.
>>
>>> +       struct mii_bus *mdio;
>>> +       struct phy_device *phydev;
>>> +       char phy_name[20];
>>> +       u16 phy_addr;
>>> +       u16 oldmode;
>>> +};
>>> +
>
> [...]
>
>>> +       /* are we using the internal or the external phy? */
>>> +       ret = asix_read_cmd(dev, AX_CMD_SW_PHY_STATUS, 0, 0, 1, buf);
>>> +       if (ret < 0) {
>>> +               dbg("Failed to read software interface selection register: %d",
>>> +                   ret);
>>> +               goto free;
>>> +       }
>>> +       dbg("AX_CMD_SW_PHY_STATUS = 0x%02x\n", buf[0]);
>>> +       switch ((buf[0] & 0x0c) >> 2) {
>>> +       case 0:
>>> +               dbg("use internal phy\n");
>>> +               priv->use_embdphy = 1;
>>> +               break;
>>> +       case 1:
>>> +               dbg("use external phy\n");
>>> +               priv->use_embdphy = 0;
>>> +               break;
>>> +       default:
>>> +               dbg("Interface mode not supported by driver\n");
>>> +               goto free;
>>> +       }
>>
>> This switch statement inverts the existing logic. Much simpler code would be:
>>     /* buf[0] & 0xc describes phy interface mode */
>>     if (buf[0] &  8) {
>>          dbg("Interface mode not supported by driver\n");
>>          goto free;
>>     }
>>     priv->use_extphy = (buf[0] & 4) >> 2;
>>
>
> Thank your for your comments! I'll change that in the next version!
> Regards, Christian

After rethinking it I decided to keep the switch structure, but use
defines for the different modes and the bitmask. I think this will be
easier to understand. I will submit a new version of the patchset
later today, please have a look at it.
Thanks!
Christian
