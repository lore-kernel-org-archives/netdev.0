From: Jarno Rajahalme <jrajahalme@nicira.com>
Subject: Re: [PATCH] net: openvswitch: Support masked set actions.
Date: Wed, 10 Dec 2014 12:03:43 -0800
Message-ID: <2A734ABB-853F-4D17-91BB-1B62A784881C@nicira.com>
References: <1418170225-9328-1-git-send-email-jrajahalme@nicira.com> <20141210.144853.2074647545313560689.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog125.obsmtp.com ([74.125.149.153]:46161 "HELO
	na3sys009aog125.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756870AbaLJT4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:56:46 -0500
Received: by mail-pa0-f44.google.com with SMTP id et14so3489841pad.3
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 11:56:45 -0800 (PST)
In-Reply-To: <20141210.144853.2074647545313560689.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Dec 10, 2014, at 11:48 AM, David Miller <davem@davemloft.net> wrote:

> From: Jarno Rajahalme <jrajahalme@nicira.com>
> Date: Tue,  9 Dec 2014 16:10:25 -0800
> 
>> OVS userspace already probes the openvswitch kernel module for
>> OVS_ACTION_ATTR_SET_MASKED support.  This patch adds the kernel module
>> implementation of masked set actions.
>> 
>> The existing set action sets many fields at once.  When only a subset
>> of the IP header fields, for example, should be modified, all the IP
>> fields need to be exact matched so that the other field values can be
>> copied to the set action.  A masked set action allows modification of
>> an arbitrary subset of the supported header bits without requiring the
>> rest to be matched.
>> 
>> Masked set action is now supported for all writeable key types, except
>> for the tunnel key.  The set tunnel action is an exception as any
>> input tunnel info is cleared before action processing starts, so there
>> is no tunnel info to mask.
>> 
>> The kernel module converts all (non-tunnel) set actions to masked set
>> actions.  This makes action processing more uniform, and results in
>> less branching and duplicating the action processing code.  When
>> returning actions to userspace, the fully masked set actions are
>> converted back to normal set actions.  We use a kernel internal action
>> code to be able to tell the userspace provided and converted masked
>> set actions apart.
>> 
>> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
> 
> How does this work, should I be waiting for a signoff or ACK from
> Pravin before applying this directly to my tree?

In this case you should wait for an Acked-by from Jesse, as he has
reviewed previous versions of this patch sent to dev@openvswitch.org
only. I should have included a note about that, sorry.

Thanks,

  Jarno
