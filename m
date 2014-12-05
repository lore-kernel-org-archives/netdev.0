From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch iproute2 0/6] iproute2: add changes for switchdev
Date: Thu, 04 Dec 2014 18:28:47 -0800
Message-ID: <5481185F.9050805@cumulusnetworks.com>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us> <54806F2A.2050109@cumulusnetworks.com> <20141204143400.GC1861@nanopsycho.orion> <54807398.40201@cumulusnetworks.com> <20141204160444.GF1861@nanopsycho.orion> <5480921D.60108@cumulusnetworks.com> <CAE4R7bCyf7VBFWqEme37rf0YbTc3-s5Qka+1HMOsdMgVC3qZ-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"azhou@nicira.com" <azhou@nicira.com>,
	"ben@decadent.org.uk" <ben@decadent.org.uk>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38595 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933456AbaLEC25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 21:28:57 -0500
In-Reply-To: <CAE4R7bCyf7VBFWqEme37rf0YbTc3-s5Qka+1HMOsdMgVC3qZ-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/4/14, 12:49 PM, Scott Feldman wrote:
> On Thu, Dec 4, 2014 at 8:55 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> On 12/4/14, 8:04 AM, Jiri Pirko wrote:
>>> Thu, Dec 04, 2014 at 03:45:44PM CET, roopa@cumulusnetworks.com wrote:
>>>> On 12/4/14, 6:34 AM, Jiri Pirko wrote:
>>>>> Thu, Dec 04, 2014 at 03:26:50PM CET, roopa@cumulusnetworks.com wrote:
>>>>>> On 12/4/14, 12:57 AM, Jiri Pirko wrote:
>>>>>>> Jiri Pirko (1):
>>>>>>>     iproute2: ipa: show switch id
>>>>>>>
>>>>>>> Scott Feldman (5):
>>>>>>>     bridge/fdb: fix statistics output spacing
>>>>>>>     bridge/fdb: add flag/indication for FDB entry synced from offload
>>>>>>>       device
>>>>>>>     bridge/link: add new offload hwmode swdev
>>>>>> Ack to most patches but nack on this one. The todo list still has a
>>>>>> note to
>>>>>> revist the flag to indicate switchdev offloads.
>>>>>> Exposing this to userspace does not help that.
>>>>> Hmm, note that this is already exposed to userspace, this patchset is
>>>>> for iproute2 (userspace tool).
>>>> hmmm, all feedback on the switchdev patches seemed to indicate we can
>>>> change
>>>> this later.
>>>> I don't see swdev mode being used in the kernel anywhere today.
>>> Well, it is, in rocker:
>>> $ git grep BRIDGE_MODE_SWDEV
>>> drivers/net/ethernet/rocker/rocker.c:                   if (mode !=
>>> BRIDGE_MODE_SWDEV)
>>> drivers/net/ethernet/rocker/rocker.c:   u16 mode = BRIDGE_MODE_SWDEV;
>>> include/uapi/linux/if_bridge.h:#define BRIDGE_MODE_SWDEV        2       /*
>>> Full switch device offload */
>>
>> The problem is rocker is not the only one who is going to be using this. And
>> so, we need something that fits everybody.
>> And i am not going to make my user set a mode for him to enable offload to
>> hw.
>>
>>>> I will send a patch to remove it. Its still in net-next and so can be
>>>> changed
>>>> ?.
>>>> I was going to resend my patch to introduce a common offload flag for all
>>>> link objects.
>>>> It would be nice if all of them had a consistent flag to indicate hw
>>>> offload
>>>> and iproute2 could display the same flag for all.
>>>> Including bonds and vxlan's.
>>> I do not understand the connection with BRIDGE_MODE_SWDEV. We discussed
>>> this already. BRIDGE_MODE_SWDEV is a bridge mode, similar to for example
>>> BRIDGE_MODE_VEPA and makes perfect sense to have it.
>> I dont think everybody acked it. But it went in with a note saying that it
>> can be changed.
> I thought that was the plan: this new mode goes in now for net-next
> and iproute2, and you would supply follow up patch for each to move to
> your switch port flag.  That will give us time to review your work
> without have net-next and iproute2 out-of-sync.
>
>>>
>>> How vxlan and bonds come into the mixture, that is a puzzler for me.
>>> Maybe I have to see patches.
>>
>> I had posted a version of the patch previously:
>> http://www.spinics.net/lists/netdev/msg305472.html
>>
>> I have a v2 patch in my stack which does not touch the netlink header.
>> But in the past hour, i have been thinking about it some more. Do we really
>> need this set by the user ?. In my use case i don't need it.
> Look at how iproute2 figures out if SELF should be set or not.  It's
> only set if hwmode is set, otherwise it defaults to MASTER.  So with
> SWDEV a new hwmode, we can push settings (learning, leraning_sync) to
> port with SELF set.  It's probably not an ideal arrangement having to
> set hwmode each time, but this was the low-touch change to iproute2 to
> push port settings.
Did not know about this. Thanks for the info.
>
> I'm hoping your new patch will kind of straighten this all out.  But
> you've got extra work to make sure backward compat with older iproute2
> still works, including this weirdness around hwmode.
>
>> We do need a feature flag (or net_device_flags), but it does not need to be
>> set by the user explicitly.
>> This flag can be set by the switch port driver on the switch ports. And the
>> logical device: bridge/bond/vxlan
>> can inherit it from the port. There was a need of a flag in some usecases,
>> to control offloading of specific bridge port flags
>> to hw/sw (example learning in hw or sw). example patch:
>> https://patchwork.ozlabs.org/patch/413211/
>>
>> I will post something today.
> Can you include matching iproute2 changes?  (Assuming you'll building
> on top of what's already in net-next and this iproute2 set Jiri sent
> out).  It's helpful to see the iproute2 changes to see what the new
> cmd structure is and how legacy is handled.
Just sent what ever i had. Take a look and let me know.

Thanks,
Roopa


>
