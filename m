From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Wed, 31 May 2017 15:40:33 -0700
Message-ID: <CAM_iQpWicK0XySQ+L+DtVi2e2hUZx7w9CL0hC-kOaQsdbpXKtw@mail.gmail.com>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja> <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
 <20170531122752.siaou43verg4epep@nataraja> <CAM_iQpU517NR1xsrDrAohnESdS33WoToHsdGD0yOWSiGU9Yiqg@mail.gmail.com>
 <20170531181108.3kv5xqszwv5ub7cy@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37257 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751274AbdEaWk7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 18:40:59 -0400
Received: by mail-wm0-f47.google.com with SMTP id d127so37817956wmf.0
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 15:40:59 -0700 (PDT)
In-Reply-To: <20170531181108.3kv5xqszwv5ub7cy@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 11:11 AM, Harald Welte <laforge@gnumonks.org> wrote:
> I mean, what is the *use case* for loosing any refrence to a physical
> network device and unregistering it from the stack?  Is there any API by
> which a new netdevice structure can be instantiated on the actual
> hardware?  Registering the netdev is what the driver does during
> discovering the system hardware.  If there's a method to "automagically"
> loose devices, at the very least I wold expect some reasonable method to
> resurrect them.  Unloading the kernel module and reloading it is for
> sure not elegant, particularly not if you have multiple Ethernet
> devices/ports sharing the same driver.
>
> One could e.g. also think of something like a special namespace that
> collects all the "orphan" netdevices.  Something analogous to the old
> Unix tradition of "pid 1" collecting all the orphan tasks whose parents
> died.  Transferring them into that "netdev orphanage" could
> automatically set the link down so that no accidential
> routing/forwarding of traffic between the devices is possible.

Understand.

But you have other choices than using the physical interface
directly in non-root ns, for example, creating a virtual pair and
connect it with the physical one with a bridge. There are various
ways to achieve this.
