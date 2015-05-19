From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 14:17:04 -0700
Message-ID: <555BA850.1090901@gmail.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com> <555B5CBF.1090902@redhat.com> <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com> <555B77E5.5060006@redhat.com> <99014381-25AB-416D-8E09-C431B5CD5A6C@intel.com> <555B9F74.3040004@redhat.com> <DA06AAB6-CE9B-4A27-B60D-8F55BB52A063@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35962 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257AbbESVRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 17:17:06 -0400
In-Reply-To: <DA06AAB6-CE9B-4A27-B60D-8F55BB52A063@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2015 02:04 PM, Rustad, Mark D wrote:
>> On May 19, 2015, at 1:39 PM, Alexander Duyck <alexander.h.duyck@redhat.com> wrote:
>>
>> So how does this improve boot time anyway?  The original patch description said this improved boot time and reduced memory usage but I have yet to find where any of those gains would actually occur.  If you can point me in that direction I might have a better idea of the motivations behind this.
> I have to admit that you won't find them in the kernel, but systems that read VPD in the course of starting up will benefit by not reading lots of useless stuff so slowly. At least those reads will be slow on any device that reads VPD from slow hardware. Since the kernel would never perform any of those reads itself, in isolation the kernel has no benefit. However the system gets a benefit.
>
> I can delete the reference to a memory benefit, since it would be a fleeting benefit at most and not a kernel memory footprint issue.
>
> This is not a big deal for me. If you don't see the value, drop it. Some people are interested in speeding up boot. Apparently VPD is now being accessed in parallel by user space as a result of such work, exposing the problem addressed in the other patch. I saw this opportunity while trying to resolve that issue. If it isn't worth it, drop it.

Any chance you could point me toward the software in question?  Just 
wondering because it seems like what you are fixing with this is an 
implementation issue in the application since you really shouldn't be 
accessing areas outside the scope of the VPD data structure, and doing 
so is undefined in terms of what happens if you do.

- Alex
