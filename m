From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC: bring UP 'lo' by default after creating new netns
Date: Thu, 29 Jun 2017 20:08:58 -0500
Message-ID: <87efu22set.fsf@xmission.com>
References: <CAF2d9jhTcVgLHs_iqw+RRS=WhMtRF0ra5SygGMymuYQUW6HP0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Eric Dumazet <edumazet@google.com>, adobriyan@gmail.com,
        David Miller <davem@davemloft.net>, xiyou.wangcong@gmail.com,
        linux-netdev <netdev@vger.kernel.org>
To: =?utf-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS1?=
         =?utf-8?B?4KS+4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35040 "EHLO
        out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751333AbdF3BQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 21:16:17 -0400
In-Reply-To: <CAF2d9jhTcVgLHs_iqw+RRS=WhMtRF0ra5SygGMymuYQUW6HP0A@mail.gmail.com>
        (Mahesh Bandewar's message of "Thu, 29 Jun 2017 16:57:39 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Mahesh Bandewar (महेश बंडेवार)" <maheshb@google.com> writes:

> Creation of new network namespace is almost always followed up by
> bringing up the loopback device.
>
>         ip netns add foo
>         ip -netns foo link set lo up
>
> I'm not sure if there are any consequences of bringing the device UP
> at the creation of network-namespace.

Hard coded in net/core/net_namespace.c:copy_net_ns is definitely the
wrong place in the code for something like this.  If this lives anywhere
it should live in driver/net/loopback.c, or possibly in
net/core/dev.c:net_dev_init.

If we want this we want to match what we do when we the primary network
namespace.  Just so that there are no unneeded surprises with network
namespaces.

Eric
