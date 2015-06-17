From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH V3 0/2] pci: Provide a flag to access VPD through function
 0
Date: Wed, 17 Jun 2015 10:23:53 -0700
Message-ID: <5581AD29.2040406@gmail.com>
References: <20150603184445.109080.36387.stgit@mdrustad-wks.jf.intel.com> <051B68B4-3E77-4EB0-B9FE-8523631884A2@intel.com> <45099CC7-DDAB-41D9-AB74-5A81E2AAF64C@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <45099CC7-DDAB-41D9-AB74-5A81E2AAF64C@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/17/2015 09:29 AM, Rustad, Mark D wrote:
> + Alex
>
>> On Jun 5, 2015, at 2:59 PM, Rustad, Mark D <mark.d.rustad@intel.com> wrote:
>>
>>> On Jun 3, 2015, at 11:46 AM, Mark D Rustad <mark.d.rustad@intel.com> wrote:
>>>
>>> Many multi-function devices provide shared registers in extended
>>> config space for accessing VPD. The behavior of these registers
>>> means that the state must be tracked and access locked correctly
>>> for accesses not to hang or worse. One way to meet these needs is
>>> to always perform the accesses through function 0, thereby using
>>> the state tracking and mutex that already exists.
>>>
>>> To provide this behavior, add a dev_flags bit to indicate that this
>>> should be done. This bit can then be set for any non-zero function
>>> that needs to redirect such VPD access to function 0. Do not set
>>> this bit on the zero function or there will be an infinite recursion.
>>>
>>> The second patch uses this new flag to invoke this behavior on all
>>> multi-function Intel Ethernet devices.
>>>
>>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>>>
>>> ---
>>> Changes in V2:
>>> - Corrected a spelling error in a log message
>>> - Added checks to see that the referenced function 0 is reasonable
>>> Changes in V3:
>>> - Don't leak a device reference
>>> - Check that function 0 has VPD
>>> - Make a helper for the function 0 checks
>>> - Moved a multifunction check to the quirk patch
>> So does this series look acceptable now? I think I addressed the issues that Alex raised. Can these also be considered for -stable?
> More than a week has passed without any comment. Is this going to be accepted or is there still an issue?

Yeah, this looks like it has addressed most of the corner cases so I am 
good with it.

Acked-by: Alexander Duyck <alexander.h.duyck@redhat.com>
