From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 1/8] net/flower: Introduce hardware offload support
Date: Wed, 2 Mar 2016 13:14:39 +0200
Message-ID: <CAJ3xEMje78ZB4SyBMKQWBDW2304NDK7R4UJiJsOPm4BjH84a7g@mail.gmail.com>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
	<1456842290-7844-2-git-send-email-amir@vadai.me>
	<20160301144719.GA2098@nanopsycho.orion>
	<56d5c71f.a151c20a.cf0a8.ffffd4ad@mx.google.com>
	<20160301170128.GG2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amir@vadai.me>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34130 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbcCBLOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 06:14:40 -0500
Received: by mail-io0-f172.google.com with SMTP id m184so14066949iof.1
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 03:14:40 -0800 (PST)
In-Reply-To: <20160301170128.GG2098@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 7:01 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Tue, Mar 01, 2016 at 05:49:27PM CET, amir@vadai.me wrote:
>>On Tue, Mar 01, 2016 at 03:47:19PM +0100, Jiri Pirko wrote:
>>> Tue, Mar 01, 2016 at 03:24:43PM CET, amir@vadai.me wrote:
>>> >This patch is based on a patch made by John Fastabend.

>>> >It adds support for offloading cls_flower.
>>> >A filter that is offloaded successfully by hardware, will not be added to
>>> >the hashtable and won't be processed by software.

>>> That is wrong. User should explicitly specify to not include rule into sw
>>> by SKIP_KERNEL flag (does not exist now, with John's recent patch we'll
>>> have only SKIP_HW). Please add that in this patchset.

>> Why? If a rule is offloaded, why would the user want to reprocess it by software?

>> If the user use SKIP_HW, it will be processed by SW. Else, the user
>> would want it to be processed by HW or fallback to SW. I don't
>> understand in which case the user would like to have it done twice.

> For example if you turn on the offloading by unsetting NETIF_F_HW_TC.
> Or if someone inserts skbs into rx path directly, for example pktgen.
> We need SKIP_KERNEL to be set by user, not implicit.

As discussed in netdev, we want to have three modes for TC offloads

1. SW only
2. HW only (and err if can't)
3. HW and if not supported fallback to SW

Now, from your reply, I understand we want a fourth mode

4. Both (HW and SW)

Do we agree that these four policies/modes make sense?

So you want #4 to be the default? can you elaborate why? note that for
the HW marking
case a "both" mode will be very inefficient, also for actions like
vlan push/pop, encap/decap, etc
the result will be just wrong... I don't think this should be the default.

Or.
