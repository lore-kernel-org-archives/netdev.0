From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Sun, 18 Sep 2011 12:55:06 -0700
Message-ID: <CA+55aFwmwYXzC_4q+XuEAx3ta6U-jf=NvMcAc-J+4DBxLm8Efg@mail.gmail.com>
References: <20110918.022125.1554085675403900813.davem@davemloft.net>
 <CA+55aFxc1tMCXKBV33PVD5BybTLBpfJAEcObvoQwbwqbKOsp7g@mail.gmail.com>
 <20110918192333.GA1641@x4.trippels.de> <1316375164.31335.18.camel@edumazet-laptop>
 <20110918194818.GB1641@x4.trippels.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33626 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273Ab1IRTz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2011 15:55:27 -0400
In-Reply-To: <20110918194818.GB1641@x4.trippels.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 18, 2011 at 12:48 PM, Markus Trippelsdorf
<markus@trippelsdorf.de> wrote:
>
> The following works for me:

No it doesn't. It may *compile* for you, but it doesn't work for you.
It avoids all the other stuff that tcp_syn_flood_action() also does
(notably the printout).

The real fix looks to be either:

 - make an empty (inline/macro) cookie_v4_init_sequence() for the
non-syncookie config case

OR

 - change tcp_syn_flood_action() to have an inline wrapper that always
returns 0 for the non-syncookie config case so that the compiler can
see statically that when syncookies are disabled, it will always
return zero.

Or something like that.

Tssk. David, linux-next may not be fully operational, but by -rc6 you
shouldn't have sent me stuff like this that was even *remotely*
complex anyway.

Stop it.

                   Linus
