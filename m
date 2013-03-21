From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Thu, 21 Mar 2013 14:23:47 -0700
Message-ID: <CAHo-Oow3D1haZ8MzV7B0boc-fzL-S7DT+6QuOEgQCSYcvenXsQ@mail.gmail.com>
References: <1363553608.4752.5.camel@lb-tlvb-eilong.il.broadcom.com>
	<CANP3RGdZHMTPT6FTbYzSOHkrNq4seF1WcXjysQ6=HEp0A_CxWg@mail.gmail.com>
	<1363601182.4752.13.camel@lb-tlvb-eilong.il.broadcom.com>
	<20130318.131318.138158829629301794.davem@davemloft.net>
	<CAHo-OoxaaLLXtAZcx99m7p5=Hez3gpUWxvoQAgksyG3PRZH-Ng@mail.gmail.com>
	<CAHo-OowoWD_BT2W8ok32pcSmcshXttpErna-X92Ojz_A8es8iw@mail.gmail.com>
	<CAHo-Ooz2W_jcbbOFLvihf+N-6fVSNoj0jGKTT8AXoOSC3_3DRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: eilong@broadcom.com, eric.dumazet@gmail.com, dmitry@broadcom.com,
	netdev@vger.kernel.org, yuvalmin@broadcom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:63897 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab3CUVXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:23:48 -0400
Received: by mail-ve0-f170.google.com with SMTP id 14so2892084vea.1
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 14:23:47 -0700 (PDT)
In-Reply-To: <CAHo-Ooz2W_jcbbOFLvihf+N-6fVSNoj0jGKTT8AXoOSC3_3DRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just as an update on the state here.

Extensive testing both in lab and in deployment confirms the already
applied patch fixes the problem.

My concerns about aggregate counters being wrong (after taking another
long look at the data from the 'bad' run)
was simply a matter of me getting mixed up in what was the 'correct'
value I should be seeing.

ie. I did not actually see any bad behaviour with this patch.

That said.  I spent a fair bit of time debugging this before I
realized I was stupid, and found other problems
while doing that.  I cannot actually trigger the potential problems,
but I'll follow up to this with a couple patches
to fix potential problems (and export more stats).

(a) The DIFF_64 macro is buggy in the case of underflow due to unsigned-ness
(b) Any code which does SUB/ADD should instead do ADD/SUB, because
SUB(A,B) is implemented via DIFF(A,B) and thus doesn't actually do
subtraction, but instead does A := max(A-B, 0)
(c) there's a bunch of extra statistics it is trivial to export via
ethtool which make debugging stuff like this much easier
