From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] decnet: dn_rtmsg: Improve input length sanitization
 in dnrmg_receive_user_skb
Date: Thu, 08 Jun 2017 10:39:46 -0400 (EDT)
Message-ID: <20170608.103946.1162801326439212865.davem@davemloft.net>
References: <20170607141429.5781-1-mjurczyk@google.com>
        <20170607141839.GD18283@breakpoint.cc>
        <CAPr8fOQNP+y78xJqx5BNUfY6Rmjj2R8+jrz3Ett1SgdY+a5WLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: mjurczyk@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57298 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdFHOjt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:39:49 -0400
In-Reply-To: <CAPr8fOQNP+y78xJqx5BNUfY6Rmjj2R8+jrz3Ett1SgdY+a5WLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mateusz Jurczyk <mjurczyk@google.com>
Date: Wed, 7 Jun 2017 16:41:57 +0200

> On Wed, Jun 7, 2017 at 4:18 PM, Florian Westphal <fw@strlen.de> wrote:
>> Mateusz Jurczyk <mjurczyk@google.com> wrote:
>>> Verify that the length of the socket buffer is sufficient to cover the
>>> nlmsghdr structure before accessing the nlh->nlmsg_len field for further
>>> input sanitization. If the client only supplies 1-3 bytes of data in
>>> sk_buff, then nlh->nlmsg_len remains partially uninitialized and
>>> contains leftover memory from the corresponding kernel allocation.
>>> Operating on such data may result in indeterminate evaluation of the
>>> nlmsg_len < sizeof(*nlh) expression.
>>>
>>> The bug was discovered by a runtime instrumentation designed to detect
>>> use of uninitialized memory in the kernel. The patch prevents this and
>>> other similar tools (e.g. KMSAN) from flagging this behavior in the future.
>>
>> Instead of changing all the internal users wouldn't it be better
>> to add this check once in netlink_unicast_kernel?
>>
> 
> Perhaps. I must admit I'm not very familiar with this code
> area/interface, so I preferred to fix the few specific cases instead
> of submitting a general patch, which might have some unexpected side
> effects, e.g. behavior different from one of the internal clients etc.
> 
> If you think one check in netlink_unicast_kernel is a better way to do
> it, I'm happy to implement it like that.

Until we decide to add the check to netlink_unicast_kernel(), I'm applying
this and queueing it up for -stable.

Thanks.
