From: Timothy Meade <zt.tmzt@gmail.com>
Subject: Re: [RFC PATCH] platform: Faciliatate the creation of pseduo-platform
	busses
Date: Tue, 3 Aug 2010 20:41:58 -0400
Message-ID: <AANLkTint-H1zcUh0dsJUt6irm_HLbiBrFi+KurOkwq8D@mail.gmail.com>
References: <4C58A7AA.8020007@codeaurora.org>
	<20100803235631.GA17759@suse.de>
	<4C58AE15.6090900@codeaurora.org>
	<20100804000945.GA19729@suse.de>
	<4C58B1B6.9050005@quicinc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"damm@opensource.se" <damm@opensource.se>,
	"lethal@linux-sh.org" <lethal@linux-sh.org>,
	"rjw@sisk.pl" <rjw@sisk.pl>, "dtor@mail.ru" <dtor@mail.ru>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick Pannuto <ppannuto@quicinc.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C58B1B6.9050005@quicinc.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 3, 2010 at 8:17 PM, Patrick Pannuto <ppannuto@quicinc.com> =
wrote:
>>>>>
>>>>> =A0 =A0struct platform_device sub_bus1 =3D {
>>>>> =A0 =A0 =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D "sub_bus1",
>>>>> =A0 =A0 =A0 =A0 =A0 =A0.id =A0 =A0 =A0 =A0 =A0 =A0 =3D -1,
>>>>> =A0 =A0 =A0 =A0 =A0 =A0.dev.bus =A0 =A0 =A0 =A0=3D &my_bus_type,
>>>>> =A0 =A0}
>>>>> =A0 =A0EXPORT_SYMBOL_GPL(sub_bus1);
>>>>
>>>> You really want a bus hanging off of a bus? =A0Normally you need a=
 device
>>>> to do that, which is what I think you have here, but the naming is=
 a bit
>>>> odd to me.
>>>>
>>>> What would you do with this "sub bus"? =A0It's just a device, but =
you are
>>>> wanting it to be around for something.
>>>>
>>>
>>> It's for power management stuff, basically, there are actual physic=
al buses
>>> involved that can be completely powered off IFF all of their device=
s are
>>> not in use. Plus it actually matches bus topology this way.
>>
>> Then create a real bus hanging off of a device, not another device t=
hat
>> "acts" like a bus here, right? =A0Or am I missing the point?
>>
>
> The motivation for doing it this was is that one driver could drive
> devices on two different subbusses. =A0In the example, "my-driver" co=
uld
> drive a device on sub_bus1 AND sub_bus2 (if there were 2+ devices, on=
e
> or more on each bus).
>
> From my understanding, this is not possible if they are actually
> different busses.

This could be quite useful on the Qualcomm devices where there are
many collections of "devices" that resemble a bus but cannot be
directly enumerated but are initialized by platform code or possibly
in future, a device tree.  One such bus is made up of SMI devices that
are identified to the applications core by the modem firmware and can
be in the form of character devices (smd), network devices (rmnet) rpc
router channel and others, we also have to deal with the MDDI video
bus which represented a challenge when migrating the HTC Rhodium to
2.6.32 as each mdp device (and others in later kernels) are added to
the platform bus dynamically, though they don't appear similararly
group in sysfs due to not actaully being on a bus.  While it would
have been possible to implement an mddi bus, the work would have
essentially recreated the platform bus with a new name.  A simliar
challenge exists for exposing rpc endpoints to userspace as the
current codebase uses character devices rather than introducing a new
network protocol to the kernel, if such as bus was exposed through
sysfs a userspace daemon could easily bind a GPS library to the PDAPI
endpoint or similar features requiring less configuration to adapt to
new AMSS firmware or device name layout.

Thank you,
Timothy Meade
tmzt #htc-linux
facebook.com/HTCLinux
