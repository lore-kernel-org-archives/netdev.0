From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH v6 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Thu, 27 Apr 2017 11:21:51 +0200
Message-ID: <CAHmME9qDmcvzF_xeaxegC2RpBOs8PziJOaKEqv6Z_X1pUFbR0w@mail.gmail.com>
References: <20170425155215.4835-1-Jason@zx2c4.com> <20170425184734.26563-1-Jason@zx2c4.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>
To: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Laight <David.Laight@aculab.com>,
        kernel-hardening@lists.openwall.com,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:57783 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1032291AbdD0JVy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 05:21:54 -0400
In-Reply-To: <20170425184734.26563-1-Jason@zx2c4.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Dave,

David Laight and I have been discussing offlist. It occurred to both
of us that this could just be turned into a loop because perhaps this
is actually just tail-recursive. Upon further inspection, however, the
way the current algorithm works, it's possible that each of the
fraglist skbs has its own fraglist, which would make this into tree
recursion, which is why in the first place I wanted to place that
limit on it. If that's the case, then the patch I proposed above is
the best way forward. However, perhaps there's the chance that
fraglist skbs having separate fraglists are actually forbidden? Is
this the case? Are there other parts of the API that enforce this
contract? Is it something we could safely rely on here? If you say
yes, I'll send a v7 that makes this into a non-recursive loop.

Regards,
Jason
