From: Andy Green <andy.green@linaro.org>
Subject: Re: [PATCH 6/7] net: wireless: wcn36xx: remove powersaving for wcn3620
Date: Tue, 10 Feb 2015 06:01:17 +0800
Message-ID: <CAAfg0W5NBuipJKB3w8md9eA8bMWAotQpSAA+GKA7qDvBsCphfg@mail.gmail.com>
References: <20150118050741.31866.36490.stgit@114-36-241-182.dynamic.hinet.net>
	<20150118051111.31866.39208.stgit@114-36-241-182.dynamic.hinet.net>
	<CAJAp7OhcFTuYfc7JOKW1SrVRbucuSWg5jcFaoVnSDgBxsyo2ng@mail.gmail.com>
	<CAAfg0W6dPupGLgwDF5FtNqEFvC4Y+GvFBAmXWcUQwXr2y6KugQ@mail.gmail.com>
	<CAJAp7OjLDCzLYeb3LHNs1sOHWM64XZWzr46UQ2vNirH_2JibNg@mail.gmail.com>
	<CAAfg0W58Wssa=OKRSGtxY4rQJCzP0uTw__Rd278fc1v7Q0fqUw@mail.gmail.com>
	<CAJAp7Ojpgm=U+AmBSEZrOpv_B7aGpa-rNPiXPjoDbRTS6C84Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	wcn36xx <wcn36xx@lists.infradead.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>
To: Bjorn Andersson <bjorn@kryo.se>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <CAJAp7Ojpgm=U+AmBSEZrOpv_B7aGpa-rNPiXPjoDbRTS6C84Tw@mail.gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10 February 2015 at 05:40, Bjorn Andersson <bjorn@kryo.se> wrote:
> On Mon, Feb 9, 2015 at 1:28 PM, Andy Green <andy.green@linaro.org> wrote:
>> On 10 February 2015 at 05:11, Bjorn Andersson <bjorn@kryo.se> wrote:
>>> On Feb 9, 2015 1:07 PM, "Andy Green" <andy.green@linaro.org> wrote:
>>>>
>>>> On 10 February 2015 at 01:54, Bjorn Andersson <bjorn@kryo.se> wrote:
>>>> > On Sat, Jan 17, 2015 at 9:11 PM, Andy Green <andy.green@linaro.org>
> [..]
>>>> At that point I think a nice solution would be a donation of time from
>>>> guys who specialize in wcn for a living to come and hand out a pony or
>>>> two...
>>>>
>>>
>>> I agree, my goal is that we get this running in mainline (smd, smsm, smp2p
>>> and remoteproc-tz) so that people with the domain knowledge can go in and
>>> make it work well.
>>
> [..]
>>
>> Can I ask if smdtty will also appear?  I uplevelled and hacked smdtty
>> a bit from a 3.10 reference tree for 8916-qrd, and I was able to get
>> wcn3620 BT working stably for BT keyboard + mouse and even ad2p.
>>
>> However the hack bound together smdtty ch2 + 3 in smdtty driver and
>> made it understand about the missing hci protocol byte... this is far
>> from reasonable for upstream, but it works like the 3.10 except needs
>> no special bluez / userland treatment.  So I'm curious if no smdtty
>> how the split smd hci / acl link in firmware will appear coherently to
>> userspace as a normal uart.
>>
>
> I'm not entirely sure how we're to proceed with this one.
>
> In msm-3.4 with BlueZ the kernel has a driver named hci_smd, that
> consumes the two channels and register with the hci core.
>
> In msm-3.10 Qualcomm have dropped this, because they are running
> bluedroid which instead consumes the two smd channels in userspace
> (through the smd_pkt driver).
>
> We need smd_pkt for modem related matters anyways, so on that we can
> run bluedroid and we could bring in hci_smd for use with BlueZ. But
> then we would have to configure the kernel based on what stack we want
> to run on top.
>
> So we should probably look into userspace and try to consolidate
> things there before deciding where to take this.

I understand, although it's a shame to make a whole new protocol in
bluez when it's just the normal protocol with a byte trimmed at the
start of a block.  It can work with stock distro bluez out of the box
if the kernel binds the channels.

The hci_smd thing sounds okay, maybe he can be a module and Android /
bluedroid just doesn't have the module in the rootfs, traditional
Linux gets the module and udev inserts him.

-Andy

> Regards,
> Bjorn
