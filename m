From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: sk_buff and reference counting netdev pointers
Date: Mon, 23 Jan 2017 15:45:08 -0800
Message-ID: <CAM_iQpXKsFA5ZZmBvqJaTJ8H88GmoTRmU0HT=FHH8hPrDxX_4Q@mail.gmail.com>
References: <E593AEBC-5FD1-4CEF-A119-2C032DB574FC@me.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Joel Cunningham <joel.cunningham@me.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34833 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdAWXpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 18:45:30 -0500
Received: by mail-wm0-f66.google.com with SMTP id d140so30381454wmd.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 15:45:30 -0800 (PST)
In-Reply-To: <E593AEBC-5FD1-4CEF-A119-2C032DB574FC@me.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 2:37 PM, Joel Cunningham <joel.cunningham@me.com> w=
rote:
> Hi,
>
> I=E2=80=99m working on a research effort to understand the synchronizatio=
n mechanisms for accessing and modifying a struct net_device object.  One a=
rea that isn=E2=80=99t clear is the net device pointer (dev) stored in a st=
ruct sk_buff.  From my investigation, the pointer appears to be assigned wi=
thout increasing the struct net_device=E2=80=99s reference count (example _=
_netdev_alloc_skb doesn=E2=80=99t call dev_hold) and also when the sk_buff =
is freed (kfree_skb) no call to dev_put() is made.  This seems to leave a p=
ossibility of an skb referencing a stale net device unless something is cle=
aning up all the skbs during unregister_netdevice() (which waits for all ou=
tstanding references to be released).  Any insight in understanding how thi=
s is working would be appreciated!
>

This is a very common question.

synchronize_net() is supposed to wait for on-flying packets, since
both for TX and RX paths we acquire RCU read lock.
