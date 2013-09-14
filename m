From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [RFC PATCH 2/4] net: Add lower dev list helpers
Date: Sat, 14 Sep 2013 23:14:37 +0200
Message-ID: <20130914211437.GB18327@redhat.com>
References: <20130911184441.26914.10336.stgit@nitbit.x32>
 <20130911184647.26914.40440.stgit@nitbit.x32>
 <20130914122756.GA18327@redhat.com>
 <5234CA5D.5020603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: stephen@networkplumber.org, bhutchings@solarflare.com,
	ogerlitz@mellanox.com, john.ronciak@intel.com,
	netdev@vger.kernel.org, shannon.nelson@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756393Ab3INVQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Sep 2013 17:16:29 -0400
Content-Disposition: inline
In-Reply-To: <5234CA5D.5020603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 14, 2013 at 01:43:09PM -0700, John Fastabend wrote:
>On 09/14/2013 05:27 AM, Veaceslav Falico wrote:
>>On Wed, Sep 11, 2013 at 11:46:49AM -0700, John Fastabend wrote:
>>>This patch adds helpers to traverse the lower dev lists, these
>>>helpers match the upper dev list implementation.
>>>
>>>VSI implementers may use these to track a list of connected netdevs.
>>>This is easier then having drivers do their own accounting.
>>
>>Just as a note (as I have quite no idea how ixgbe works) - you are aware
>>that the upper/lower lists currently include *all* upper/lower devices, and
>>not only the first-connected ones?
>
>Yep, the netif_is_vsi_port() should hopefully catch all the cases.
>
>>
>>I've seen that you usually verify it, however not always, just a heads-up -
>>sorry if misread.
>
>I'll audit it again, maybe I missed a case.

It was about lower devices, and I think I've just really misread it -
indeed they can be only 'your' devices.

>
>>
>>I'm also currently trying to get the new patchset included - which would
>>split the first-tier connected devices from all the 'other' (as in - lower
>>of a lower and upper of an upper) devices, so that way, I think, it would
>>be easier/faster for you to use it. It also has a ->private field, easily
>>accessible, which you could have used instead of/in conjunction with/for
>>struct ixgbe_vsi_adapter.
>
>Yeah I saw the patch set I'll use the improved lists once I see the
>series gets applied. Although in my case the list walking only occurs in
>the configuration path so its not critical.
>
>Also the net device structure already has private space to hang the
>device dependent structure off of, so I'm not sure having another
>private field helps here.

Yep, it should/can be used when linking devices which might already be
using their private space for their own structures, which is not your case,
I suppose.

>
>Thanks,
>John
>
>-- 
>John Fastabend         Intel Corporation
