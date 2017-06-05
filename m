From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] netlink: don't send unknown nsid
Date: Mon, 5 Jun 2017 10:40:24 +0200
Message-ID: <58321cd0-6c7f-d4d8-628f-2c124d71ef82@6wind.com>
References: <4942f9fe-625b-bb97-7b45-4a1e8bf69b1b@6wind.com>
 <1496304007-1962-1-git-send-email-nicolas.dichtel@6wind.com>
 <20170601170246.GF2673@x240.lan>
 <75fccaea-0ebe-1a2a-27d7-ad30fd99f41d@6wind.com>
 <20170601224454.GG2673@x240.lan>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:35270 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751574AbdFEIk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 04:40:28 -0400
Received: by mail-wr0-f171.google.com with SMTP id q97so34255480wrb.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 01:40:28 -0700 (PDT)
In-Reply-To: <20170601224454.GG2673@x240.lan>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/06/2017 à 00:44, Flavio Leitner a écrit :
> On Thu, Jun 01, 2017 at 10:42:13PM +0200, Nicolas Dichtel wrote:
>> Le 01/06/2017 à 19:02, Flavio Leitner a écrit :
[snip]
>>> On the other hand, with the original patch, if the socket and the
>>> device are in the same netns, we don't need to report any ID.  Previous
>>> kernels did that, so we are not breaking anything.  When the netns
>>> differs, then we either should report the real ID or an error.
>>>
>> I don't understand. With or without my last patch, the kernel sends netlink
>> messages of other netns than the netns where the socket is opened, only if an
>> nsid is assigned.
> 
> "only if an nsid is assigned" that's the issue.
It was design like that because it's not legitimate to unconditionally listen
all netns of the system. Isolation between namespaces must be respected
(scenarii with containers, etc.).
When a nsid is assigned to a peer netns, it's a way to say "ok, I know this
netns and I have access to it".

> 
> Let me ask this instead: How do you think userspace should behave when
> netnsid allocation fails?
> 
There is two ways to assign a nsid:
 - manually with netlink ('ip netns set'). In this case, the error is reported
   to userspace via netlink.
 - automatically when a x-netns interface is created. The link-nsid is also
   reported to userspace. If the allocation failed, NETNSA_NSID_NOT_ASSIGNED is
   reported. And if you were able to create this x-netns interface, it means
   that you have access to this peer netns, thus you can try to assign the nsid
   manually.
So, in both cases, userland knows that something went wrong.

Do you have another scenario in mind?


Nicolas
