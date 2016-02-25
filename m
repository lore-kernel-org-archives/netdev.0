From: Ross Green <rgkernel@gmail.com>
Subject: Re: wlcore: Fix regression in wlcore_set_partition()
Date: Thu, 25 Feb 2016 15:56:29 +1100
Message-ID: <CANfgCY1NqeOw0jiNVSyWYL60jcLtqVeVHP8v3hj=jZaDAQFpcg@mail.gmail.com>
References: <20160210012216.GA18819@lianli>
	<20160212094526.EC572611CE@smtp.codeaurora.org>
	<CANfgCY02_AkRi2EMNZsneK8UdwLvAWxF_X0ts6WZbaM0=5c63A@mail.gmail.com>
	<87bn7gu19c.fsf@kamboji.qca.qualcomm.com>
	<CANfgCY0zHtE8Z8knNPsTgnZS-fumdeioU45F1E2KtvpLBckQDg@mail.gmail.com>
	<CANfgCY04juY=xaJ88UN9NE+T9Xne+AEczitjj7vrLxtG_eb+AA@mail.gmail.com>
	<20160225001146.GA1839@lianli>
	<CANfgCY0a843dUG_ssJ-PP70F8MAROrvKOQe9cH0GewnShV8tqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11410efa705e52052c9101d9
Cc: Kalle Valo <kvalo@codeaurora.org>, Shahar Patury <shaharp@ti.com>,
	Guy Mishol <guym@ti.com>,
	Igor Grinberg <grinberg@compulab.co.il>,
	Uri Mashiach <uri.mashiach@compulab.co.il>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
To: Emil Goode <emil.fsw@goode.io>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANfgCY0a843dUG_ssJ-PP70F8MAROrvKOQe9cH0GewnShV8tqg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--001a11410efa705e52052c9101d9
Content-Type: text/plain; charset=UTF-8

On Thu, Feb 25, 2016 at 1:13 PM, Ross Green <rgkernel@gmail.com> wrote:
> On Thu, Feb 25, 2016 at 11:11 AM, Emil Goode <emil.fsw@goode.io> wrote:
>> Hello Ross
>>
>> On Wed, Feb 24, 2016 at 04:40:50PM +1100, Ross Green wrote:
>>> On Wed, Feb 17, 2016 at 4:34 PM, Ross Green <rgkernel@gmail.com> wrote:
>>> > Appreciate your efforts!
>>> >
>>> > Just trying to make sure it does not get lost.
>>> > Introduced in rc1, not fixed by ... rc4.
>>> >
>>> > Anyway, I will continue to test, lots of other things still to chase
>>> > even in rc4!
>>> >
>>> > Regards,
>>> >
>>> > Ross Green
>>> >
>>> > On Wed, Feb 17, 2016 at 2:24 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
>>> >> Ross Green <rgkernel@gmail.com> writes:
>>> >>
>>> >>> On Fri, Feb 12, 2016 at 8:45 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
>>> >>>>
>>> >>>>> The commit 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio") introduced a
>>> >>>>> regression causing the wlcore to time out and go into recovery. Reverting the
>>> >>>>> changes regarding write of the last partition size brings the module back to
>>> >>>>> it's functional state.
>>> >>>>>
>>> >>>>> Fixes: 3719c17e1816 ("wlcore/wl18xx: fw logger over sdio")
>>> >>>>> Reported-by: Ross Green <rgkernel@gmail.com>
>>> >>>>> Signed-off-by: Emil Goode <emil.fsw@goode.io>
>>> >>>>> [kvalo@codeaurora.org: improved commit log]
>>> >>>>
>>> >>>> Thanks, applied to wireless-drivers.git.
>>> >>>>
>>> >>>> Kalle Valo
>>> >>>
>>> >>> I just tested linux-4.5-rc4 it appears the above fix missed the release for rc4!
>>> >>> So the behaviour of firmware reset being called after the access of
>>> >>> the last partition timesout.
>>> >>>
>>> >>> Again tested patch with the new release - 4.5-rc4 and found everything
>>> >>> to work as expected again.
>>> >>>
>>> >>> So Hopefully for rc5 - Please!
>>> >>
>>> >> It takes some time to get patches into Linus' tree. And being in a
>>> >> conference and then getting sick is not really helping. I'm not sure if
>>> >> this patch makes to rc5 on time, but I'll try.
>>> >>
>>> >> --
>>> >> Kalle Valo
>>>
>>> G'day all,
>>>
>>> I have tested Emil's patch with each 4.5-rc release.
>>>
>>> Seems to work fine with rc2, rc3, rc4.
>>> I tried it with rc5 and get the following output from dmesg see attachment.
>>>
>>> So it looks like there is a reset that it recovers from and then proceeds OK.
>>>
>>> I see the patch has been queued by David Miller so it might make it into rc6.
>>> That will be great. It still does not look quite as clean as it should
>>> be however, given the noise in the dmesg output from rc5
>>>
>>> Regards,
>>>
>>>
>>> Ross Green
>>
>> I'm unable to reproduce that ELP wakeup timeout with v4.5-rc5 on my pandaboard es.
>> Can you easily reproduce it and are you able to reproduce it with commit 3719c17e1816 reverted?
>>
>> However, I'm seeing another bug that occurs when the wlan is not configured to connect to
>> an AP directly after boot (dmesg attached). It is not related to any recent changes and goes back
>> before the 3.14 kernel. There seem to be an issue with the looped IRQ handling implementation.
>> A scan on 2GHZ is performed and the wlcore_fw_status() call in wlcore_irq_locked() returns
>> WL1271_ACX_INTR_HW_AVAILABLE, then nothing seem to happen until the delayed work queue
>> scan_complete_work starts executing after the 30 sec timeout runs out and the wlcore goes into
>> recovery. I guess a new scan should be initiated after wlcore_fw_status() return hw available,
>> does anyone have input on that?
>>
>> Best regards,
>>
>> Emil Goode
>
>
> Sorry Emil had not tried a reboot since getting that message. The wifi
> module did recover and associate properly after that. So I just kept
> on using the system.
>
> Trying to track down another problem that takes "AGES" before it shows
> up so just kept the system running. Hoping to get some debug regarding
> and RCU problem.
>
> I will check it again later when i get a chance to reboot.
>
> At least with your patch in place the system will keep functioning.
> Plus I had not noticed any problems running rc2, rc3, rc4 with your
> patch in place.
> Everything behaved pre the 4.5 changes.
>
> I'll get back to you with what I find. It does look however that there
> might be some other problems sitting there that possibly the new
> changes show up more. Some slightly different timing situations.
>
> Regards,
>
> Ross Green

G'day Emil,

Just tried a reboot of the pandaboard es with the patches applied to
the 4.5-rc5.

Everything worked fine!!!

So it might be a strange timing thing that happens "sometimes".

the wl processor is running its own software from the firmware
downloaded, there might be times when it accessed too soon.

So there are still a few things to watch with the changes that have
been been added during 4.5. I had assumed that this driver had been
fairly stable for some time,
but there might have always been a few problems lurking.

attached is a small section of the dmesg output, showing good working
order for the wl driver.


Regards,

Ross Green

--001a11410efa705e52052c9101d9
Content-Type: application/octet-stream; name="dmesg-4.5-rc5-wlcore-2"
Content-Disposition: attachment; filename="dmesg-4.5-rc5-wlcore-2"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_il1sq3x40

WyAgIDU3LjI0NTk0MV0gd2xjb3JlOiBsb2FkZWQKWyAgIDcxLjcwNzM5N10gd2xjb3JlOiBmaXJt
d2FyZSBib290ZWQgKFJldiA2LjMuMTAuMC4xMzMpClsgICA3NS4yNzc4MzJdIHdsYW4wOiBhdXRo
ZW50aWNhdGUgd2l0aCA5MDpmNjo1Mjo4MTplZTo3MApbICAgNzUuMzEwNjY4XSB3bGFuMDogc2Vu
ZCBhdXRoIHRvIDkwOmY2OjUyOjgxOmVlOjcwICh0cnkgMS8zKQpbICAgNzUuMzE4ODE3XSB3bGFu
MDogYXV0aGVudGljYXRlZApbICAgNzUuMzI5OTg2XSB3bGFuMDogYXNzb2NpYXRlIHdpdGggOTA6
ZjY6NTI6ODE6ZWU6NzAgKHRyeSAxLzMpClsgICA3NS4zNDA3MjhdIHdsYW4wOiBSWCBBc3NvY1Jl
c3AgZnJvbSA5MDpmNjo1Mjo4MTplZTo3MCAoY2FwYWI9MHg0MzEgc3RhdHVzPTAgYWlkPTEpClsg
ICA3NS4zNTYwNDhdIHdsYW4wOiBhc3NvY2lhdGVkClsgICA3NS40MTM0ODJdIHdsY29yZTogQXNz
b2NpYXRpb24gY29tcGxldGVkLgojIAoKCgoK
--001a11410efa705e52052c9101d9--
