From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [PATCH net-next] netlink: include netnsid only when netns
 differs.
Date: Wed, 31 May 2017 09:28:36 -0300
Message-ID: <20170531122836.GV2673@x240.lan>
References: <20170530213325.21652-1-fbl@sysclose.org>
 <1b83c01b-8fe3-8e9b-cae7-4064527c1c21@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sender-of-o52.zoho.com ([135.84.80.217]:21456 "EHLO
        sender-of-o52.zoho.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751037AbdEaM2q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 08:28:46 -0400
Content-Disposition: inline
In-Reply-To: <1b83c01b-8fe3-8e9b-cae7-4064527c1c21@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 10:38:21AM +0200, Nicolas Dichtel wrote:
> Le 30/05/2017 à 23:33, Flavio Leitner a écrit :
> > Don't include netns id for notifications broadcasts when the
> > socket and the skb are in the same netns because it will be
> > an error which can't be distinguished from a peer netns failing
> > to allocate an id.
> I don't understand the problem. peernet2id() doesn't allocate ids, it only do a
> lookup. If you need an id for the current netns, you have to allocate one.

The issue is that if you query an interface on the same netns, the
error is returned, then we cannot tell if the iface is on the same
netns or if there was an error while allocating the ID and the
iface is on another netns.

> This patch changes the metadata exported to the userland and will break existing
> tools.

It should not break because it changes only for interfaces on
the same netns where there is no ID and that value wasn't
exported until recently.

-- 
Flavio
