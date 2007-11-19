From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0 (was: Strange behavior in arp probe reply, bug or feature?)
Date: Mon, 19 Nov 2007 16:06:10 +0300
Message-ID: <20071119130610.GB6952@ms2.inr.ac.ru>
References: <cac0ab7d0711150340p58eda94ah92894072ba328205@mail.gmail.com> <20071115154032.GA30391@ms2.inr.ac.ru> <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Jonas Danielsson <the.sator@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754721AbXKSNG3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Is there a reason that the target hardware address isn't the target
> hardware address?

It is bound only to the fact that linux uses protocol address
of the machine, which responds. It would be highly confusing
(more than confusing :-)), if we used our protocol address and hardware
address of requestor.

But if you use zero protocol address as source, you really can use
any hw address.

> The dhcp clients I examined, and the implementation of the arpcheck
> that I use will compare the target hardware field of the arp-reply and
> match it against its own mac, to verify the reply. And this fails with
> the current implementation in the kernel.

1. Do not do this. Mainly, because you already know that this does not work
   with linux. :-) Logically, target hw address in arp reply is just
   a nonsensial redundancy, it should not be checked and even looked at.

2. What's about your suggestion, I thought about this and I am going to agree.

   Arguments, which convinced me are:

   - arping still works.
   - any piece of reasonable software should work.
   - if Windows understands DaD (is it really true? I cannot believe)
     and it is unhappy about our responce and does not block use
     of duplicate address only due to this, we _must_ accomodate ASAP.
   - if we do,we have to use 0 protocol address, no choice.

Alexey
