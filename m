From: Christian Riesch <christian.riesch@omicron.at>
Subject: Re: [PATCH 4/4] asix: Add a new driver for the AX88172A
Date: Mon, 9 Jul 2012 12:30:24 +0200
Message-ID: <CABkLOboHQ9Fxdo5W-B8LGXT5gXFhMFHvO5OSasVDdZ5XtuMKqA@mail.gmail.com>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
	<1341574388-7464-5-git-send-email-christian.riesch@omicron.at>
	<1341596255.2923.7.camel@bwh-desktop.uk.solarflarecom.com>
	<1341761975.2038.28.camel@schesaplana>
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
Received: from mail-gg0-f174.google.com ([209.85.161.174]:47256 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721Ab2GIKaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:30:25 -0400
Received: by gglu4 with SMTP id u4so9887462ggl.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:30:24 -0700 (PDT)
In-Reply-To: <1341761975.2038.28.camel@schesaplana>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben and Michael,

On Sun, Jul 8, 2012 at 5:39 PM, Michael Riesch <michael@riesch.at> wrote:
> On Fri, 2012-07-06 at 18:37 +0100, Ben Hutchings wrote:
>> > +   priv->mdio->priv = (void *)dev;
>> > +   priv->mdio->read = &asix_mdio_bus_read;
>> > +   priv->mdio->write = &asix_mdio_bus_write;
>> > +   priv->mdio->name = "Asix MDIO Bus";
>> > +   snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%s",
>> > +            dev_name(dev->net->dev.parent));
>> [...]
>>
>> I think you need to ensure that the bus identifier is unique throughout
>> its lifetime, but net devices can be renamed and that could lead to a
>> collision.  Perhaps you could use the ifindex or the USB device path
>
> Ben,
>
> the dev_name function in the code above returns the sysfs filename of
> the USB device (e.g. 1-0:1.0).
>
>> (though that might be too long).
>
> This may be a problem. The bus identifier may be 17 characters long, so
> if we leave the endpoint/configuration part (:1.0) and the prefix away
> it should be fine in any "normal" system. However, on a system with a
> more-than-9-root-hubs 5-tier 127-devices-each USB infrastructure it
> results in collisions. So is this approach acceptable?
>
> Using the ifindex sounds good to me,
>
> snprintf(priv->mdio->id, MII_BUS_ID_SIZE, "asix-%d",
>         dev->net->ifindex);
>
> works on any system with less than 10^12 network interfaces.

Ok, I'll change that to use ifindex. I didn't like the mdio bus name
with lots of colons, dashes, and periods anyway...
Thank you!

Regards, Christian
