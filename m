From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Wed, 11 Jul 2012 17:10:14 +0200
Message-ID: <CABkLObq+JtgECK=Q6dxOgDEZ++GxfLzutHGbWzt2uD5LStKjwg@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
	<1341596255.2923.7.camel@bwh-desktop.uk.solarflarecom.com>
	<1341761975.2038.28.camel@schesaplana>
	<CABkLOboHQ9Fxdo5W-B8LGXT5gXFhMFHvO5OSasVDdZ5XtuMKqA@mail.gmail.com>
	<CABkLObo5v00QKo-X7hEVbMcXA_QwKFA6HfL-Le5VvU2J5Cs2eg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>
To: michael@riesch.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:38860 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758058Ab2GKPKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 11:10:15 -0400
Received: by gglu4 with SMTP id u4so1314298ggl.19
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 08:10:14 -0700 (PDT)
In-Reply-To: <CABkLObo5v00QKo-X7hEVbMcXA_QwKFA6HfL-Le5VvU2J5Cs2eg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again,

On Wed, Jul 11, 2012 at 10:27 AM, Christian Riesch
<christian.riesch@omicron.at> wrote:
> Hi Ben and Michael,
>
> On Mon, Jul 9, 2012 at 12:30 PM, Christian Riesch
> <christian.riesch@omicron.at> wrote:
>> Hi Ben and Michael,
>>
>> On Sun, Jul 8, 2012 at 5:39 PM, Michael Riesch <michael@riesch.at> wrote:
>>> On Fri, 2012-07-06 at 18:37 +0100, Ben Hutchings wrote:
>>>> > +   priv->mdio->priv = (void *)dev;
>>>> > +   priv->mdio->read = &asix_mdio_bus_read;
>>>> > +   priv->mdio->write = &asix_mdio_bus_write;
>>>> > +   priv->mdio->name = "Asix MDIO Bus";
>>>> > +   snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%s",
>>>> > +            dev_name(dev->net->dev.parent));
>>>> [...]
>>>>
>>>> I think you need to ensure that the bus identifier is unique throughout
>>>> its lifetime, but net devices can be renamed and that could lead to a
>>>> collision.  Perhaps you could use the ifindex or the USB device path
>>>
>>> Ben,
>>>
>>> the dev_name function in the code above returns the sysfs filename of
>>> the USB device (e.g. 1-0:1.0).
>>>
>>>> (though that might be too long).
>>>
>>> This may be a problem. The bus identifier may be 17 characters long, so
>>> if we leave the endpoint/configuration part (:1.0) and the prefix away
>>> it should be fine in any "normal" system. However, on a system with a
>>> more-than-9-root-hubs 5-tier 127-devices-each USB infrastructure it
>>> results in collisions. So is this approach acceptable?
>>>
>>> Using the ifindex sounds good to me,
>>>
>>> snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%d",
>>>         dev->net->ifindex);
>>>
>>> works on any system with less than 10^12 network interfaces.
>>
>> Ok, I'll change that to use ifindex.
>
> No, I won't.
> At the time the mdio bus is registered, ifindex is not yet set, so the
> snprintf would always result in "asix-0".

What do you think about
snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "usb-%03d:%03d",
dev->udev->bus->busnum, dev->udev->devnum);
??

This would use the busnum/devnum identifier as reported by lsusb and
would be short enough for an mdio bus name.

Thanks, Christian
