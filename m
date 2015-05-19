From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Limit VPD reads for all Intel
 Ethernet devices
Date: Tue, 19 May 2015 16:42:02 -0700
Message-ID: <555BCA4A.2080400@redhat.com>
References: <20150519000042.56109.69779.stgit@mdrustad-wks.jf.intel.com> <555B5CBF.1090902@redhat.com> <4AD84211-965C-4F0B-A7F4-3E6CCE6567E3@intel.com> <555B77E5.5060006@redhat.com> <99014381-25AB-416D-8E09-C431B5CD5A6C@intel.com> <555B9F74.3040004@redhat.com> <DA06AAB6-CE9B-4A27-B60D-8F55BB52A063@intel.com> <555BA850.1090901@gmail.com> <46CDD500-2A1B-4457-BE17-961AFC50769E@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57279 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751132AbbESXmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 19:42:08 -0400
In-Reply-To: <46CDD500-2A1B-4457-BE17-961AFC50769E@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 05/19/2015 03:43 PM, Rustad, Mark D wrote:
>> On May 19, 2015, at 2:17 PM, Alexander Duyck <alexander.duyck@gmail.com> wrote:
>>
>> Any chance you could point me toward the software in question?  Just wondering because it seems like what you are fixing with this is an implementation issue in the application since you really shouldn't be accessing areas outside the scope of the VPD data structure, and doing so is undefined in terms of what happens if you do.
> I don't have it, but if you dump VPD via sysfs you will see it comes out as 32k in size. The kernel just blindly provides access to the full 32K space provided by the spec. I'm sure that we agree that the kernel should not go parse it and find the actual size. If it is read via stdio, say fread, the read access would be whatever buffer size it chooses to use.
>
> If you looked at the quirks, you might have noticed that Broadcom limited the VPD access for some devices for functional reasons. That is what gave me the idea for limiting access to what was possibly there. With the existing Intel Ethernet quirk, it seemed like a simple thing to do.

Actually we probably should be parsing through the VPD data.  The PCIe 
spec doesn't define what happens if you read past the end marker, and I 
suspect most applications are probably performing sequential reads of 
the data instead of just accessing offsets anyway since that is how this 
is really meant to be accessed.  So if we moved this to a sequenced 
interface instead of a memory mapped style interface it would probably 
work out better anyway since we could perform multiple reads in sequence 
instead of one at a time.

- Alex
