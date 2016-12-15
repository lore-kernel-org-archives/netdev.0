From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 2/2] net/sched: cls_flower: Use masked key when
 calling HW offloads
Date: Thu, 15 Dec 2016 16:43:45 +0100
Message-ID: <20161215154344.GA24984@penelope.horms.nl>
References: <20161215145931.GA1807@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Blakey <paulb@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36889 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758480AbcLOPoQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 10:44:16 -0500
Received: by mail-wm0-f52.google.com with SMTP id t79so51851440wmt.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 07:43:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161215145931.GA1807@nanopsycho.orion>
 <ec30629a-063d-3ff2-d2d7-2e710f7d6779@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 04:12:05PM +0200, Or Gerlitz wrote:
> On 12/15/2016 3:50 PM, Simon Horman wrote:
> >>Zero bits on the mask signify a "don't care" on the corresponding bits
> >>in key. Some HWs require those bits on the key to be zero. Since these
> >>bits are masked anyway, it's okay to provide the masked key to all
> >>drivers.
> >>
> >>Fixes: 5b33f48842fa ('net/flower: Introduce hardware offload support')
> >>
> >While I don't have a specific use case in mind that this change would break
> >it seems to me that it would be better to handle hardware requirements
> >at the driver level.
> 
> Simon, again, since these bits are masked anyway, it would be correct to
> provide the masked key to the hw device.
> 
> E.g no matter if the flow key/mask provided to the HW device is is
> 1.1.1.10/24  or 1.1.1.0/24, the user expects to the same matching, so
> nothing can't happen if we provide the latter to the driver.

> >While I don't have a specific use case in mind that this change would break
> >it seems to me that it would be better to handle hardware requirements
> >at the driver level.
> 
> Even though, makes no sense to pass unmasked key down. Is is only
> confusing. This patch fixes it.

It seems somewhat arbitrary to me to allow such filters in software
but not pass then down to the driver layer. But I don't feel strongly
about this and I am happy for the patch to progress as-is.
