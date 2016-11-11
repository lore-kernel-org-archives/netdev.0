From: Mathias Nyman <mathias.nyman@linux.intel.com>
Subject: Re: [PATCH] usbnet: prevent device rpm suspend in usbnet_probe
 function
Date: Fri, 11 Nov 2016 16:44:50 +0200
Message-ID: <5825D962.9090807@linux.intel.com>
References: <Pine.LNX.4.44L0.1611081339060.1499-100000@iolanthe.rowland.org>
 <1478692735.2428.10.camel@suse.com> <8760nwj0l3.fsf@miraculix.mork.no>
 <CAAd53p5W4xpSYsFZ00deQDh-gZBijn_ApreE9NmC=_B_MAQaug@mail.gmail.com>
 <87a8d7h9q1.fsf@miraculix.mork.no> <1478776957.2428.15.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Kai-Heng Feng <kai.heng.feng@canonical.com>,
        Alan Stern <stern@rowland.harvard.edu>,
        linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>,
        =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478776957.2428.15.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10.11.2016 13:22, Oliver Neukum wrote:
> On Thu, 2016-11-10 at 12:09 +0100, Bjørn Mork wrote:
>> Kai-Heng Feng <kai.heng.feng@canonical.com> writes:
>>> On Wed, Nov 9, 2016 at 8:32 PM, Bjørn Mork <bjorn@mork.no> wrote:
>>>> Oliver Neukum <oneukum@suse.com> writes:
>>>>
>>>>> On Tue, 2016-11-08 at 13:44 -0500, Alan Stern wrote:
>>>>>
>>>>>> These problems could very well be caused by running at SuperSpeed
>>>>>> (USB-3) instead of high speed (USB-2).
>>>
>>> Yes, it's running at SuperSpeed, on a Kabylake laptop.
>>>
>>> It does not have this issue on a Broadwell laptop, also running at SuperSpeed.
>>
>> Then I must join Oliver, being very surprised by where in the stack you
>> attempt to fix the issue.  What you write above indicates a problem in
>> pci bridge or usb host controller, doesn't it?
>
> Indeed. And this means we need an XHCI specialist.
> Mathias, we have a failure specific to one implementation of XHCI.
>


Could be related to resume singnalling time.
Does the xhci fix for it in 4.9-rc3 help?

commit 7d3b016a6f5a0fa610dfd02b05654c08fa4ae514
     xhci: use default USB_RESUME_TIMEOUT when resuming ports.

It doesn't directly explain why it would work on Broadwell but not Kabylake,
but it resolved very similar cases.

If not, then adding dynamic debug for xhci could show something.

-Mathias
