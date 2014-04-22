From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net: Implement SO_PEERCGROUP and SO_PASSCGROUP
 socket options
Date: Tue, 22 Apr 2014 16:29:27 -0400 (EDT)
Message-ID: <20140422.162927.2182797573155988911.davem@davemloft.net>
References: <1397596546-10153-1-git-send-email-vgoyal@redhat.com>
	<20140422.160558.627080587952506099.davem@davemloft.net>
	<CALCETrWHA5ZmzOHnz9LO+7v4byc8QiynGyjE_ju5sjokNqrjZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vgoyal@redhat.com, linux-kernel@vger.kernel.org,
	cgroups@vger.kernel.org, netdev@vger.kernel.org, tj@kernel.org,
	ssorce@redhat.com, lpoetter@redhat.com, kay@redhat.com,
	dwalsh@redhat.com
To: luto@amacapital.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758495AbaDVU33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 16:29:29 -0400
In-Reply-To: <CALCETrWHA5ZmzOHnz9LO+7v4byc8QiynGyjE_ju5sjokNqrjZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 22 Apr 2014 13:08:59 -0700

> On Tue, Apr 22, 2014 at 1:05 PM, David Miller <davem@davemloft.net> wrote:
>> From: Vivek Goyal <vgoyal@redhat.com>
>> Date: Tue, 15 Apr 2014 17:15:44 -0400
>>
>>> This is another version of patchset to add support passing cgroup
>>> information of client over unix socket API.
>>
>> I'm marking this patch series as "changes requested" in patchwork
>> because if we still end up adding this feature SO_PASSCGROUP needs to
>> be changed to behave like SO_PASSCRED.
>>
>> Specifically, like SO_PASSCRED, it should pass the "real" cgroup, ie.
>> the cgroup at socket open() time.
>>
> 
> I suspect that making this change will render it useless,
> unfortunately.  I really want to understand the use case.

There was no use case, it is simply the fact that when I discussed this
feature with Vivek and Simo I told them that it should be implemented
the same as the existing credential facilities.

For datagram situations there is no "peer" to consider in between
sendmsg() calls, as the binding is only active during the sendmsg()
call.

That's why SO_PASSCRED exists in the first place.

Otherwise, without SO_PASSCGROUP, there is no way for datagram sockets
to find out the peer's open() time cgroup.
