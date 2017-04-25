From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] macsec: avoid heap overflow in skb_to_sgvec on
 receive
Date: Tue, 25 Apr 2017 17:51:40 +0200
Message-ID: <20170425155140.GA13414@bistromath.localdomain>
References: <f50ef5b9e525d83938f5e419557abb0307ee023b.1493133423.git.sd@queasysnail.net>
 <CAHmME9rxdTEe1-5ApgUhdkqiJztSgJb0QuhV2uSemobeXm_oNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52802 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1431570AbdDYPvn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 11:51:43 -0400
Content-Disposition: inline
In-Reply-To: <CAHmME9rxdTEe1-5ApgUhdkqiJztSgJb0QuhV2uSemobeXm_oNg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-25, 17:39:09 +0200, Jason A. Donenfeld wrote:
> Hi Sabrina,
> 
> I think I may have beaten you to the punch here by a few minutes. :)

I said I was going to post a patch.
Mail headers seem to disagree with you ;)


> The difference between our two versions is that you don't re-add the
> FRAGLIST attribute, whereas my patch does, and then it does the
> dynamic allocation. I suspect this might be a bit more robust. It also
> ensures that skb_cow_data is called on both paths. So perhaps let's
> roll with mine?

I don't see the "more robust" argument.

Unless I missed something, encrypt was already handling fragments
correctly. An skb with ->frag_list should have no skb_tailroom, so it
will be linearized skb_copy_expand().

-- 
Sabrina
