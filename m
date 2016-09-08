From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
Date: Thu, 8 Sep 2016 15:32:45 -0400 (EDT)
Message-ID: <401753600.83187028.1473363165519.JavaMail.zimbra@redhat.com>
References: <CAJD3hpUgNJPOqGmAp7tEaY2+EnOasG=W6VLOMbEhDRgr8M5v8A@mail.gmail.com> <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jojy Varghese <jojy.varghese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:38208 "EHLO
        mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941343AbcIHTcs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 15:32:48 -0400
In-Reply-To: <CAJD3hpUSqSxtgJMK__V-j8VKRwf-ftZFHw0J38VTxP9tDDZyhA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Jojy Varghese" <jojy.varghese@gmail.com>
> To: netdev@vger.kernel.org
> Cc: davem@davemloft.net
> Sent: Thursday, September 8, 2016 3:08:29 PM
> Subject: Re: [PATCH] net_namespace: fixed net_device reference leak
> 
> (Updating the patch for the case when a non-loopback dev could be
> unregistered)
> 
> Currently during namespace cleanup, if ‘dst’ subsystem is holding
> a reference to the interface in the namespace, it does not get released.
> Current code first does a ’dev_hold’ on the same device followed by a
> ‘dev_put’ on the same device resulting in a no-op.
> 
> This change fixes this leak by assigning the initial namespace’s loopback
> device to the ‘dst’ before releasing the reference to the network
> device being released.
> 
> Additional reference: https://github.com/docker/docker/issues/5618
> 
> Signed-off-by: Jojy G Varghese <jojy.varghese@gmail.com>
> ---

If the dst wasn't being cleaned up in the namespace that's being deleted,
it is unlikely it will be cleaned up after moving it to the init namespace.

I think it would be better to figure out why this dst is being leaked
in the first place, otherwise this is probably still a memory leak.

Is this easily reproducible with current net or net-next kernels?

Regards,

    Lance
