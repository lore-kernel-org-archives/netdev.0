From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC][PATCH 0/4] RFS hardware acceleration
Date: Mon, 20 Sep 2010 12:36:20 -0700
Message-ID: <AANLkTikS8y0sCbA7wcAfV2i6L+UYQ14d-3dL5jg55Atq@mail.gmail.com>
References: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Bob Felderman <feldy@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:61877 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757135Ab0ITTg0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 15:36:26 -0400
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o8KJaMVA026793
	for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 12:36:22 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by kpbe14.cbf.corp.google.com with ESMTP id o8KJaKeT005919
	for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 12:36:20 -0700
Received: by pwj1 with SMTP id 1so1467715pwj.6
        for <netdev@vger.kernel.org>; Mon, 20 Sep 2010 12:36:20 -0700 (PDT)
In-Reply-To: <1285009290.2282.121.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ben, this does look interesting.  We'll try to take a look.


On Mon, Sep 20, 2010 at 12:01 PM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> Tom,
>
> This patch series extends RFS to use hardware RX filters where
> available. =A0Depending on the number of hardware RX queues and their
> IRQs' affinity, this should reduce the need for IPIs or at least get
> packets delivered to the right NUMA node.
>
> I've implemented the driver side of this for our hardware, though I
> don't know whether you have any of that to test on. =A0I would be ver=
y
> interested to know how much this can help in the sort of cases where =
you
> use RFS.
>
> Ben.
>
> Ben Hutchings (4):
> =A0IRQ: IRQ groups for multiqueue devices
> =A0net: RPS: Enable hardware acceleration
> =A0sfc: Implement RFS acceleration
> =A0sfc/RFS/irq_group debug output
>
> =A0drivers/net/sfc/efx.c =A0 =A0 | =A0 49 +++++++++++---
> =A0drivers/net/sfc/efx.h =A0 =A0 | =A0 =A09 +++
> =A0drivers/net/sfc/filter.c =A0| =A0109 +++++++++++++++++++++++++++++
> =A0include/linux/irq.h =A0 =A0 =A0 | =A0 52 ++++++++++++++
> =A0include/linux/netdevice.h | =A0 29 +++++++-
> =A0kernel/irq/manage.c =A0 =A0 =A0 | =A0170 +++++++++++++++++++++++++=
++++++++++++++++++++
> =A0net/core/dev.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 88 +++++++++++++++++++=
+++--
> =A07 files changed, 488 insertions(+), 18 deletions(-)
>
> --
> 1.7.2.1
>
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
