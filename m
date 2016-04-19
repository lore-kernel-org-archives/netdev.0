From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v5] rtnetlink: add new RTM_GETSTATS message to
 dump link stats
Date: Tue, 19 Apr 2016 09:45:32 +0200
Message-ID: <5715E21C.1090108@6wind.com>
References: <1461013819-23223-1-git-send-email-roopa@cumulusnetworks.com>
 <20160418.234137.26692086759328024.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37277 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbcDSHpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 03:45:36 -0400
Received: by mail-wm0-f53.google.com with SMTP id n3so14533272wmn.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 00:45:35 -0700 (PDT)
In-Reply-To: <20160418.234137.26692086759328024.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 19/04/2016 05:41, David Miller a =E9crit :
[snip]
> I just tested out a clever idea, where for architectures where
> unaligned accesses is a problem, we insert a zero length NOP attribut=
e
> before the 64-bit stats.  This makes it properly aligned.  A quick
> hack patch just passed testing on my sparc64 box, but I'll go over it
> some more.
We saw also problems with architectures like tilera.

Just for reminder, there was a first attempt by Thomas to make this pat=
ch
generic: http://patchwork.ozlabs.org/patch/207097/

But we finally discover that some netlink API use the attribute '0'.
Ideally, it would be great to 'tell' to the libnetlink the attribute us=
ed for
padding, so that every attribute can be aligned on 8 if needed, but I d=
on't see
a way to do it without changing the whole libnetlink API (and thus all =
users).
Or could we done the opposite: using Thomas patch by default and introd=
ucing a
new API in the libnetlink for netlink messages where the attribute '0' =
is used?
Some were identified in this patch:
31e20bad8d58 ("diag: warn about missing first netlink attribute").

I like this idea, because it will fix all users, not only rtnl, but the=
 risk is
to forget someone.

Any thoughts?


Regards,
Nicolas
