From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [non-quoted-printable PATCH] Fix caif BUG() with network namespaces
Date: Mon, 24 Oct 2011 17:51:54 +0200
Message-ID: <CAJK669ar5ASsX+wEv2EwwaeBoHYtr3Uq+sG1RWroViYGOVgytw@mail.gmail.com>
References: <1319230309.19448.10.camel@shinybook.infradead.org>
	<CAJK669a0cX73J0pEr3EtCkbxsaHRfxnS-56Q3Q5ANdKd47mnrg@mail.gmail.com>
	<1319405079.13738.72.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@redhat.com" <davem@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Woodhouse, David" <david.woodhouse@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:45208 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932804Ab1JXPvy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 11:51:54 -0400
Received: by qyk4 with SMTP id 4so2370842qyk.19
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 08:51:54 -0700 (PDT)
In-Reply-To: <1319405079.13738.72.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

> The caif code will register its own pernet_operations, and then regis=
ter
> a netdevice_notifier. Each time the netdevice_notifier is triggered,
> it'll do some stuff... including a lookup of its own pernet stuff wit=
h
> net_generic().
>
> If the net_generic() call ever returns NULL, the caif code will BUG()=
=2E
> That doesn't seem *so* unreasonable, I suppose =E2=80=94 it does seem=
 like it
> should never happen.
>
> However, it *does* happen. When we clone a network namespace,
> setup_net() runs through all the pernet_operations one at a time. It
> gets to loopback before it gets to caif. And loopback_net_init()
> registers a netdevice... while caif hasn't been initialised. So the c=
aif
> netdevice notifier triggers, and immediately goes BUG().
>
> I'm not entirely sure how best to fix this in the general case. Perha=
ps
> the netdevice_notifier registration should be pernet too, rather than
> global? Or perhaps we should suppress the notifier calls during
> setup_net() and flush them at the end after everything has been
> initialised?
>
> But really, I'm inclined to just take the simple approach. Make
> caif_device_notify() *not* go looking for its pernet data structures =
if
> the device it's being notified about isn't a caif device in the first
> place. This simple patch is sufficient to avoid the problem, and is
> probably good enough.
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

Thank you for analyzing and fixing this David, this looks good to me.
Acked-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
