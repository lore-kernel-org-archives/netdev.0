From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address workaround
 on DT ethernet
Date: Mon, 27 May 2013 19:38:31 +1000
Message-ID: <1369647511.3557.27.camel@pasglop>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
	 <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com>
	 <20130525.210441.818472895703230779.davem@davemloft.net>
	 <51A26B62.4050009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, buytenh@wantstofly.org,
	jason@lakedaemon.net, andrew@lunn.ch, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51A26B62.4050009@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-05-26 at 22:06 +0200, Sebastian Hesselbarth wrote:

> good you mention it. I added Grant on Cc and will give a short
> sum-up why I casted the const from property->value away here.
> 
> Maybe I overlooked the API for modifying the DT property but as
> far as I've seen - there is no API for modifying it. And yes,
> you are right, it is kind of an abuse of DT here.

of_update_property(). That also makes sure that any notifiers
is called and proc/device-tree is updated in the case where the property
is new.

> As Kirkwoods loose their MAC address on clock gating, I was looking
> for a place to store it early. (a) DT property "local-mac-address"
> looked as a good place as it will allow the driver to find it without
> any extra code. Of course, I am doing severaly sanity checks if it is
> safe to overwrite it, i.e. no other MAC set, property is there, long
> enough.
> 
> If Grant also NACKs modifying the DT we basically have two more options
> left for Kirkwood: (b) have MAC stored early in two global arrays in
> board init and reference that from mv643xx_eth or (c) leave the clock
> ungated unconditionally on all Kirkwoods.
> 
> I can live with all three, just name it and I prepare a final patch set.

No, putting it in the DT makes sense, just use the right accessor.

Cheers,
Ben.

> Sebastian
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
