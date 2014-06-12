From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH net] rtnetlink: fix userspace API breakage for iproute2
 < v3.9.0
Date: Thu, 12 Jun 2014 16:13:09 +0200
Message-ID: <5399B575.7070604@redhat.com>
References: <1401279319-29088-1-git-send-email-mschmidt@redhat.com> <20140530.174248.715408523447246496.davem@davemloft.net> <538DBDB3.7030505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	alexander.h.duyck@intel.com, michael.riesch@omicron.at
To: David Miller <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37717 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752823AbaFLON0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 10:13:26 -0400
In-Reply-To: <538DBDB3.7030505@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/03/2014 02:21 PM, Michal Schmidt wrote:
> On 05/31/2014 02:42 AM, David Miller wrote:
>> From: Michal Schmidt <mschmidt@redhat.com>
>> Date: Wed, 28 May 2014 14:15:19 +0200
>>
>>> When running RHEL6 userspace on a current upstream kernel, "ip link"
>>> fails to show VF information.
>>>
>>> The reason is a kernel<->userspace API change introduced by commit
>>> 88c5b5ce5cb57 ("rtnetlink: Call nlmsg_parse() with correct header length"),
>>> after which the kernel does not see iproute2's IFLA_EXT_MASK attribute
>>> in the netlink request.
>>>
>>> iproute2 adjusted for the API change in its commit 63338dca4513
>>> ("libnetlink: Use ifinfomsg instead of rtgenmsg in rtnl_wilddump_req_filter").
>>>
>>> The problem has been noticed before:
>>> http://marc.info/?l=linux-netdev&m=136692296022182&w=2
>>> (Subject: Re: getting VF link info seems to be broken in 3.9-rc8)
>>>
>>> We can do better than tell those with old userspace to upgrade. We can
>>> recognize the old iproute2 in the kernel by checking the netlink message
>>> length. Even when including the IFLA_EXT_MASK attribute, its netlink
>>> message is shorter than struct ifinfomsg.
>>>
>>> With this patch "ip link" shows VF information in both old and new
>>> iproute2 versions.
>>>
>>> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
>>
>> The userspace tool should be fixed on the system, rather than having the
>> kernel cater to a user tool bug.
>>
>> I'm not applying this, sorry.
> 
> David,
> 
> the old version of the userspace tool did what it had to do in order to
> work with a contemporary kernel. You can call that a bug, but the fact
> is that it used to work that way.
> 
> I do not see a difference between "catering to a user tool bug" and
> "not breaking applications, whether we like them or not" (paraphrasing
> Linus's message on this very mailing list just 10 days ago).

Dave,
I am sorry for harping on this, but could you please either reconsider
the NAK, or explain what considerations are more important than
userspace compatibility in this case?

> I could understand your objection if my proposed patch could break
> something else, but you are not saying that, are you?

Michal
