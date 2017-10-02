From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Mon, 2 Oct 2017 11:32:45 +0200
Message-ID: <f80d9afa-0ce2-903d-9bf9-b7bb8765086b@6wind.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Mathias <mathias@hall-andersen.dk>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:52045 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751127AbdJBJcs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 05:32:48 -0400
Received: by mail-wm0-f45.google.com with SMTP id f4so1190765wme.0
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 02:32:48 -0700 (PDT)
In-Reply-To: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/09/2017 à 20:47, Jason A. Donenfeld a écrit :
> Hey guys,
> 
> It's possible to create a tun device in a process in namespace A and
> then move that interface to namespace B. The controlling process in A
> needs to receive notifications on when the interface is brought up or
> down. It can receive these notifications via netlink while the
> interface lives in A but not when it moves to B.
> 
> Any tricks or APIs to get around this?
There are two options.

1. Move the process to netns B, open the netlink socket and move back the
process to netns A. The socket will remain in netns B and you will receive all
netlink messages related to netns B.

2. Assign a nsid to netns B in netns A and use NETLINK_LISTEN_ALL_NSID on your
netlink socket (see iproute2).


Regards,
Nicolas
