From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH 1/2] ARM: kirkwood: proper retain MAC address workaround
 on DT ethernet
Date: Sun, 26 May 2013 22:06:58 +0200
Message-ID: <51A26B62.4050009@gmail.com>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com> <1369253042-15082-1-git-send-email-sebastian.hesselbarth@gmail.com> <20130525.210441.818472895703230779.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, jason@lakedaemon.net, andrew@lunn.ch,
	benh@kernel.crashing.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@linaro.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130525.210441.818472895703230779.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/26/2013 06:04 AM, David Miller wrote:
> From: Sebastian Hesselbarth<sebastian.hesselbarth@gmail.com>
> Date: Wed, 22 May 2013 22:04:01 +0200
>
>> +			memcpy((void *)p->value, reg, 6);
>
> This cast is completely unnecessary, non-void to void pointer casts
> are automatic.
>
> If it is necessary, because p->value is const, then you are trying
> to change something behind the OF layer's back and need to use
> the appropriate interface to change the property contents.

David,

good you mention it. I added Grant on Cc and will give a short
sum-up why I casted the const from property->value away here.

Maybe I overlooked the API for modifying the DT property but as
far as I've seen - there is no API for modifying it. And yes,
you are right, it is kind of an abuse of DT here.

As Kirkwoods loose their MAC address on clock gating, I was looking
for a place to store it early. (a) DT property "local-mac-address"
looked as a good place as it will allow the driver to find it without
any extra code. Of course, I am doing severaly sanity checks if it is
safe to overwrite it, i.e. no other MAC set, property is there, long
enough.

If Grant also NACKs modifying the DT we basically have two more options
left for Kirkwood: (b) have MAC stored early in two global arrays in
board init and reference that from mv643xx_eth or (c) leave the clock
ungated unconditionally on all Kirkwoods.

I can live with all three, just name it and I prepare a final patch set.

Sebastian
