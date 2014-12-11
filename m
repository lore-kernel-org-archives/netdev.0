From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] net: openvswitch: Support masked set actions.
Date: Wed, 10 Dec 2014 18:05:17 -0800
Message-ID: <CAEP_g=9mzgCJA-DRzM++c1S=tPTshb1E-2TqOot9x7MWxCyX_Q@mail.gmail.com>
References: <1418170225-9328-1-git-send-email-jrajahalme@nicira.com>
 <20141210.144853.2074647545313560689.davem@davemloft.net> <2A734ABB-853F-4D17-91BB-1B62A784881C@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jarno Rajahalme <jrajahalme@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:37658 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932937AbaLKCFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 21:05:38 -0500
Received: by mail-qg0-f54.google.com with SMTP id l89so3142823qgf.13
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 18:05:37 -0800 (PST)
In-Reply-To: <2A734ABB-853F-4D17-91BB-1B62A784881C@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2014 at 12:03 PM, Jarno Rajahalme <jrajahalme@nicira.com> wrote:
>
> On Dec 10, 2014, at 11:48 AM, David Miller <davem@davemloft.net> wrote:
>
>> From: Jarno Rajahalme <jrajahalme@nicira.com>
>> Date: Tue,  9 Dec 2014 16:10:25 -0800
>>
>>> OVS userspace already probes the openvswitch kernel module for
>>> OVS_ACTION_ATTR_SET_MASKED support.  This patch adds the kernel module
>>> implementation of masked set actions.
>>>
>>> The existing set action sets many fields at once.  When only a subset
>>> of the IP header fields, for example, should be modified, all the IP
>>> fields need to be exact matched so that the other field values can be
>>> copied to the set action.  A masked set action allows modification of
>>> an arbitrary subset of the supported header bits without requiring the
>>> rest to be matched.
>>>
>>> Masked set action is now supported for all writeable key types, except
>>> for the tunnel key.  The set tunnel action is an exception as any
>>> input tunnel info is cleared before action processing starts, so there
>>> is no tunnel info to mask.
>>>
>>> The kernel module converts all (non-tunnel) set actions to masked set
>>> actions.  This makes action processing more uniform, and results in
>>> less branching and duplicating the action processing code.  When
>>> returning actions to userspace, the fully masked set actions are
>>> converted back to normal set actions.  We use a kernel internal action
>>> code to be able to tell the userspace provided and converted masked
>>> set actions apart.
>>>
>>> Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
>>
>> How does this work, should I be waiting for a signoff or ACK from
>> Pravin before applying this directly to my tree?
>
> In this case you should wait for an Acked-by from Jesse, as he has
> reviewed previous versions of this patch sent to dev@openvswitch.org
> only. I should have included a note about that, sorry.

I gave some review comments but generally speaking my expectation is
that Pravin, as the maintainer, will provide an ack for OVS patches.
