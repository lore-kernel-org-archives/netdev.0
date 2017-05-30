From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: loosing netdevices with namespaces and unshare?
Date: Tue, 30 May 2017 16:18:17 -0700
Message-ID: <CAM_iQpW2ARBTmGK8JhVXSFCaB1F-WPDKeDZwEbxMLf_Xi7aXQw@mail.gmail.com>
References: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Harald Welte <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35273 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750922AbdE3XSj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 19:18:39 -0400
Received: by mail-wm0-f51.google.com with SMTP id b84so103850521wmh.0
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 16:18:38 -0700 (PDT)
In-Reply-To: <20170530220741.ldmhwj3bsvdoaofc@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 30, 2017 at 3:07 PM, Harald Welte <laforge@gnumonks.org> wrote:
> But, to the contrary, this doesn't happen.  The unshare-created netns is
> gone, but the netdevice did not get moved back to the root namespace
> either.  The only hack to get back to the "eth0" device is to unload the
> driver and re-load it.


Net namespace simply unregisters all netdevices inside when it is
gone, no matter where they are from. I am pretty sure you can move it
back to root-ns if you want, it is a little tricky because you have to give
the root-ns a name first.


>
> I can reproduce the above without starting any other process inside that
> namespace.  I have verified that there are no /proc/*/ns/net symlinks
> left pointing to the ID of that namespace.  What am I missing here?  Is
> this the intended behavior?

Yes it is.

>
> Of course I know I could simply do something like "ip link set eth0
> netns 1" from within the namespace before leaving.  But what if the
> process is not bash and the process exits abnormally?   I'd consider
> that explicit reassignment more like a hack than a proper solution...

It doesn't make sense to move it back to where it is from, for example,
what if you move a veth0 from netns1 to netns2 and netns1 is gone
before netns2?

Regards.
