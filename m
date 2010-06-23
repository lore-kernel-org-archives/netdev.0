From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 00000000000000a0
Date: Wed, 23 Jun 2010 10:00:58 -0700
Message-ID: <4C223DCA.5090704@gmail.com>
References: <AANLkTilf41JrFwN1veRDifNA78S2LQ6SO0g3YLOONd2W@mail.gmail.com> <20100623141622.GC15205@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	davem@davemloft.net, timo.teras@iki.fi
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:54358 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab0FWRIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 13:08:12 -0400
In-Reply-To: <20100623141622.GC15205@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o.k. the bisect is pointing to the below results..
(I tried git revert xxx but this commit is too big
so I'll(hopefully)manually revert it on the latest HEAD to
see if this is the actual problem im experiencing)



80c802f3073e84c956846e921e8a0b02dfa3755f is the first bad commit
commit 80c802f3073e84c956846e921e8a0b02dfa3755f
Author: Timo Ter=C3=A4s <timo.teras@iki.fi>
Date:   Wed Apr 7 00:30:05 2010 +0000

     xfrm: cache bundles instead of policies for outgoing flows

     __xfrm_lookup() is called for each packet transmitted out of
     system. The xfrm_find_bundle() does a linear search which can
     kill system performance depending on how many bundles are
     required per policy.

     This modifies __xfrm_lookup() to store bundles directly in
     the flow cache. If we did not get a hit, we just create a new
     bundle instead of doing slow search. This means that we can now
     get multiple xfrm_dst's for same flow (on per-cpu basis).

     Signed-off-by: Timo Teras <timo.teras@iki.fi>
     Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 d8e60f5fa4c1329f450d9c7cdf98b34e6a177f22=20
9f576e68e5bf4ce357d7f0305aee5f410250dfe2 M      include
:040000 040000 f2876df688ee36907af7b4123eea96592faaed3e=20
a3f6f6f94f0309106856cd99b38ec90b024eb016 M      net



Justin P. Mattock
