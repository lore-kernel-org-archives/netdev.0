From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net-next] netlink: include netnsid only when netns
 differs.
Date: Wed, 31 May 2017 15:34:57 -0300
Message-ID: <20170531183457.GM2673@x240.lan>
References: <20170530213325.21652-1-fbl@sysclose.org>
 <1b83c01b-8fe3-8e9b-cae7-4064527c1c21@6wind.com>
 <20170531122836.GV2673@x240.lan>
 <c4250fae-3bf8-f646-9a68-de91419b0b8b@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21431 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdEaSfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:35:04 -0400
Content-Disposition: inline
In-Reply-To: <c4250fae-3bf8-f646-9a68-de91419b0b8b@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 03:48:06PM +0200, Nicolas Dichtel wrote:
> Le 31/05/2017 à 14:28, Flavio Leitner a écrit :
> > On Wed, May 31, 2017 at 10:38:21AM +0200, Nicolas Dichtel wrote:
> >> Le 30/05/2017 à 23:33, Flavio Leitner a écrit :
> >>> Don't include netns id for notifications broadcasts when the
> >>> socket and the skb are in the same netns because it will be
> >>> an error which can't be distinguished from a peer netns failing
> >>> to allocate an id.
> >> I don't understand the problem. peernet2id() doesn't allocate ids, it only do a
> >> lookup. If you need an id for the current netns, you have to allocate one.
> > 
> > The issue is that if you query an interface on the same netns, the
> > error is returned, then we cannot tell if the iface is on the same
> > netns or if there was an error while allocating the ID and the
> > iface is on another netns.
> If the returned id is NETNSA_NSID_NOT_ASSIGNED, then the netns is the same.
> 
> Some lines before your patch, we call peernet_has_id() when the netns differ,
> thus we ensure that the id is available.

Right, but that's internal to the kernel.

> The principle was that netlink messages of other netns can be sent only if an id
> is assigned.

OK, could you please update include/uapi/linux/net_namespace.h to reflect that?
It says NETNSA_NSID_NOT_ASSIGNED are attributes for RTM_NEWNSID or RTM_GETNSID
which makes sense, but NOT_ASSIGNED sounds little like SAME_NSID for other
message types.

-- 
Flavio
