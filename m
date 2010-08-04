From: Patrick Pannuto <ppannuto@quicinc.com>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
 busses
Date: Tue, 3 Aug 2010 17:17:58 -0700
Message-ID: <4C58B1B6.9050005@quicinc.com>
References: <4C58A7AA.8020007@codeaurora.org> <20100803235631.GA17759@suse.de> <4C58AE15.6090900@codeaurora.org> <20100804000945.GA19729@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick Pannuto <ppannuto@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "dtor@mail.ru" <dtor@mail.ru>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20100804000945.GA19729@suse.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>
>>>> 	struct platform_device sub_bus1 = {
>>>> 		.name		= "sub_bus1",
>>>> 		.id		= -1,
>>>> 		.dev.bus	= &my_bus_type,
>>>> 	}
>>>> 	EXPORT_SYMBOL_GPL(sub_bus1);
>>>
>>> You really want a bus hanging off of a bus?  Normally you need a device
>>> to do that, which is what I think you have here, but the naming is a bit
>>> odd to me.
>>>
>>> What would you do with this "sub bus"?  It's just a device, but you are
>>> wanting it to be around for something.
>>>
>>
>> It's for power management stuff, basically, there are actual physical buses
>> involved that can be completely powered off IFF all of their devices are
>> not in use. Plus it actually matches bus topology this way.
> 
> Then create a real bus hanging off of a device, not another device that
> "acts" like a bus here, right?  Or am I missing the point?
> 

The motivation for doing it this was is that one driver could drive
devices on two different subbusses.  In the example, "my-driver" could
drive a device on sub_bus1 AND sub_bus2 (if there were 2+ devices, one
or more on each bus).

>From my understanding, this is not possible if they are actually
different busses.
