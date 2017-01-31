From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: sock_create_kern() and network namespace reference counts
Date: Tue, 31 Jan 2017 09:37:46 -0800
Message-ID: <CAM_iQpVs-_p8VeoRpUjBPSOCkCAi0q8gWWSx29699-UuLKQTrg@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6DB0276D58@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:38205 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750869AbdAaRje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 12:39:34 -0500
Received: by mail-wm0-f52.google.com with SMTP id r141so89239951wmg.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 09:38:08 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0276D58@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 31, 2017 at 7:41 AM, David Laight <David.Laight@aculab.com> wrote:
> Commit 26abe1437 changed sock_create_kern() so that it stopped
> holding a reference to the network namespace.
> The rational seemed to be 'to allow to stop it' (presumably 'be deleted').
> Prior to this change some kernel paths used sk_change_net() (etc) to
> change the namespace after the socket was created.
>
> If the socket doesn't hold a reference to the namespace, what actually
> happens when the namespace is deleted?

Kernel socket should have the same lifetime with the net namespace,
that is, created in net_init and released in net_exit. Think about it, if it
really held a refcnt to this netns, how could this netns be teared down?
