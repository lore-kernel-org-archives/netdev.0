From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next] netlink: include netnsid only when netns
 differs.
Date: Wed, 31 May 2017 15:48:06 +0200
Message-ID: <c4250fae-3bf8-f646-9a68-de91419b0b8b@6wind.com>
References: <20170530213325.21652-1-fbl@sysclose.org>
 <1b83c01b-8fe3-8e9b-cae7-4064527c1c21@6wind.com>
 <20170531122836.GV2673@x240.lan>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Flavio Leitner <fbl@sysclose.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37857 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750904AbdEaNsL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 09:48:11 -0400
Received: by mail-wm0-f50.google.com with SMTP id d127so20360064wmf.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 06:48:10 -0700 (PDT)
In-Reply-To: <20170531122836.GV2673@x240.lan>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 31/05/2017 à 14:28, Flavio Leitner a écrit :
> On Wed, May 31, 2017 at 10:38:21AM +0200, Nicolas Dichtel wrote:
>> Le 30/05/2017 à 23:33, Flavio Leitner a écrit :
>>> Don't include netns id for notifications broadcasts when the
>>> socket and the skb are in the same netns because it will be
>>> an error which can't be distinguished from a peer netns failing
>>> to allocate an id.
>> I don't understand the problem. peernet2id() doesn't allocate ids, it only do a
>> lookup. If you need an id for the current netns, you have to allocate one.
> 
> The issue is that if you query an interface on the same netns, the
> error is returned, then we cannot tell if the iface is on the same
> netns or if there was an error while allocating the ID and the
> iface is on another netns.
If the returned id is NETNSA_NSID_NOT_ASSIGNED, then the netns is the same.

Some lines before your patch, we call peernet_has_id() when the netns differ,
thus we ensure that the id is available.

The principle was that netlink messages of other netns can be sent only if an id
is assigned.

> 
>> This patch changes the metadata exported to the userland and will break existing
>> tools.
> 
> It should not break because it changes only for interfaces on
> the same netns where there is no ID and that value wasn't
> exported until recently.
> 
It was exported since the initial patch (59324cf35aba ("netlink: allow to listen
"all" netns"). Am I wrong?


Regards,
Nicolas
