From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch iproute2 0/6] iproute2: add changes for switchdev
Date: Thu, 4 Dec 2014 17:04:44 +0100
Message-ID: <20141204160444.GF1861@nanopsycho.orion>
References: <1417683438-10935-1-git-send-email-jiri@resnulli.us>
 <54806F2A.2050109@cumulusnetworks.com>
 <20141204143400.GC1861@nanopsycho.orion>
 <54807398.40201@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, linville@tuxdriver.com, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@redhat.com,
	john.ronciak@intel.com, mleitner@redhat.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org, hemal@broadcom.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64069 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329AbaLDQEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 11:04:46 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so35226390wiw.13
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2014 08:04:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54807398.40201@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 04, 2014 at 03:45:44PM CET, roopa@cumulusnetworks.com wrote:
>On 12/4/14, 6:34 AM, Jiri Pirko wrote:
>>Thu, Dec 04, 2014 at 03:26:50PM CET, roopa@cumulusnetworks.com wrote:
>>>On 12/4/14, 12:57 AM, Jiri Pirko wrote:
>>>>Jiri Pirko (1):
>>>>   iproute2: ipa: show switch id
>>>>
>>>>Scott Feldman (5):
>>>>   bridge/fdb: fix statistics output spacing
>>>>   bridge/fdb: add flag/indication for FDB entry synced from offload
>>>>     device
>>>>   bridge/link: add new offload hwmode swdev
>>>Ack to most patches but nack on this one. The todo list still has a note to
>>>revist the flag to indicate switchdev offloads.
>>>Exposing this to userspace does not help that.
>>Hmm, note that this is already exposed to userspace, this patchset is
>>for iproute2 (userspace tool).
>hmmm, all feedback on the switchdev patches seemed to indicate we can change
>this later.
> I don't see swdev mode being used in the kernel anywhere today.

Well, it is, in rocker:
$ git grep BRIDGE_MODE_SWDEV
drivers/net/ethernet/rocker/rocker.c:                   if (mode != BRIDGE_MODE_SWDEV)
drivers/net/ethernet/rocker/rocker.c:   u16 mode = BRIDGE_MODE_SWDEV;
include/uapi/linux/if_bridge.h:#define BRIDGE_MODE_SWDEV        2       /* Full switch device offload */

>I will send a patch to remove it. Its still in net-next and so can be changed
>?.
>I was going to resend my patch to introduce a common offload flag for all
>link objects.
>It would be nice if all of them had a consistent flag to indicate hw offload
>and iproute2 could display the same flag for all.
>Including bonds and vxlan's.

I do not understand the connection with BRIDGE_MODE_SWDEV. We discussed
this already. BRIDGE_MODE_SWDEV is a bridge mode, similar to for example
BRIDGE_MODE_VEPA and makes perfect sense to have it.

How vxlan and bonds come into the mixture, that is a puzzler for me.
Maybe I have to see patches.

>
>>
>>>>   link: add missing IFLA_BRPORT_PROXYARP
>>>>   bridge/link: add learning_sync policy flag
>>>>
>>>>  bridge/fdb.c              |  4 +++-
>>>>  bridge/link.c             | 17 +++++++++++++++--
>>>>  include/linux/if_bridge.h |  1 +
>>>>  include/linux/if_link.h   |  3 +++
>>>>  include/linux/neighbour.h |  1 +
>>>>  ip/ipaddress.c            |  8 ++++++++
>>>>  man/man8/bridge.8         | 19 ++++++++++++++-----
>>>>  7 files changed, 45 insertions(+), 8 deletions(-)
>>>>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
