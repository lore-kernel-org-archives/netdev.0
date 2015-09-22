From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net v2] openvswitch: Zero flows on allocation.
Date: Tue, 22 Sep 2015 16:57:36 -0700
Message-ID: <CALnjE+redXR+xmTM-1zsHhZ_Y32BFp=m85H53xG82mke9cWyZg@mail.gmail.com>
References: <1442892080-68516-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:33656 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934608AbbIVX5g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 19:57:36 -0400
Received: by igbkq10 with SMTP id kq10so109943541igb.0
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 16:57:36 -0700 (PDT)
In-Reply-To: <1442892080-68516-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 8:21 PM, Jesse Gross <jesse@nicira.com> wrote:
> When support for megaflows was introduced, OVS needed to start
> installing flows with a mask applied to them. Since masking is an
> expensive operation, OVS also had an optimization that would only
> take the parts of the flow keys that were covered by a non-zero
> mask. The values stored in the remaining pieces should not matter
> because they are masked out.
>
> While this works fine for the purposes of matching (which must always
> look at the mask), serialization to netlink can be problematic. Since
> the flow and the mask are serialized separately, the uninitialized
> portions of the flow can be encoded with whatever values happen to be
> present.
>
> In terms of functionality, this has little effect since these fields
> will be masked out by definition. However, it leaks kernel memory to
> userspace, which is a potential security vulnerability. It is also
> possible that other code paths could look at the masked key and get
> uninitialized data, although this does not currently appear to be an
> issue in practice.
>
> This removes the mask optimization for flows that are being installed.
> This was always intended to be the case as the mask optimizations were
> really targetting per-packet flow operations.
>
> Fixes: 03f0d916 ("openvswitch: Mega flow implementation")
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Acked-by: Pravin B Shelar <pshelar@nicira.com>
