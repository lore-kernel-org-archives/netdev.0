From: Kai-Heng Feng <kai.heng.feng@canonical.com>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe function
Date: Wed, 16 Nov 2016 18:29:29 +0800
Message-ID: <CAAd53p4k4MvDD_u3v3VcsoxEuks7S1VAM3C1REB1g3C_KiFtcg@mail.gmail.com>
References: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
 <1478692735.2428.10.camel@suse.com> <8760nwj0l3.fsf@miraculix.mork.no>
 <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
 <87a8d7h9q1.fsf@miraculix.mork.no> <1478776957.2428.15.camel@suse.com>
 <5825D962.9090807@linux.intel.com> <CAAd53p6unhMOPRux+HOB9unLy2Et47gcH5SV6H947-=_gS3DPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oneukum@suse.com>,
        =?UTF-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>,
        Alan Stern <stern@rowland.harvard.edu>,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Mathias Nyman <mathias.nyman@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAd53p6unhMOPRux+HOB9unLy2Et47gcH5SV6H947-=_gS3DPw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2016 at 3:34 PM, Kai-Heng Feng
<kai.heng.feng@canonical.com> wrote:
> On Fri, Nov 11, 2016 at 10:44 PM, Mathias Nyman
> <mathias.nyman@linux.intel.com> wrote:
>> On 10.11.2016 13:22, Oliver Neukum wrote:
>>>
>>> On Thu, 2016-11-10 at 12:09 +0100, Bj=C3=B8rn Mork wrote:
>>>>
>>>> Kai-Heng Feng <kai.heng.feng@canonical.com> writes:
>>>>>
>>>>> On Wed, Nov 9, 2016 at 8:32 PM, Bj=C3=B8rn Mork <bjorn@mork.no> wrote=
:
>>>>>>
>>>>>> Oliver Neukum <oneukum@suse.com> writes:
>>>>>>
>>>>>>> On Tue, 2016-11-08 at 13:44 -0500, Alan Stern wrote:
>>>>>>>
>>>>>>>> These problems could very well be caused by running at SuperSpeed
>>>>>>>> (USB-3) instead of high speed (USB-2).
>>>>>
>>>>>
>>>>> Yes, it's running at SuperSpeed, on a Kabylake laptop.
>>>>>
>>>>> It does not have this issue on a Broadwell laptop, also running at
>>>>> SuperSpeed.
>>>>
>>>>
>>>> Then I must join Oliver, being very surprised by where in the stack yo=
u
>>>> attempt to fix the issue.  What you write above indicates a problem in
>>>> pci bridge or usb host controller, doesn't it?
>
> Yes, I was totally wrong about that.
>
>>>
>>>
>>> Indeed. And this means we need an XHCI specialist.
>>> Mathias, we have a failure specific to one implementation of XHCI.
>>>
>>
>>
>> Could be related to resume singnalling time.
>> Does the xhci fix for it in 4.9-rc3 help?
>>
>> commit 7d3b016a6f5a0fa610dfd02b05654c08fa4ae514
>>     xhci: use default USB_RESUME_TIMEOUT when resuming ports.
>>
>> It doesn't directly explain why it would work on Broadwell but not Kabyl=
ake,
>> but it resolved very similar cases.
>>
>> If not, then adding dynamic debug for xhci could show something.
>
> I tried the latest commit, 6005a545cadb2adca64350c7aee17d002563e8c7,
> on for-usb-next branch.
>
> Now the cdc_mbim still probe failed at the first time, but somehow it
> re-probed again with a success.
>
> I reverted commit 7d3b016a6f5a0fa610dfd02b05654c08fa4ae514 and the
> behavior is the same, first time probed failed, second time probed
> success.
>
> The attached dmesg is with usbcore and xhci_hcd dynamic debug enabled.

I filed a bug report on bugzilla:
https://bugzilla.kernel.org/show_bug.cgi?id=3D187861

>
>>
>> -Mathias
>>
