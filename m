From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] macsec: avoid heap overflow in skb_to_sgvec
Date: Tue, 25 Apr 2017 17:12:48 +0200
Message-ID: <20170425151248.GB25241@bistromath.localdomain>
References: <20170421211448.16995-1-Jason@zx2c4.com>
 <20170425145340.GA25241@bistromath.localdomain>
 <CAHmME9ovUDJRDA+Td4Y0bfQZEG5pZQo1JC0nYDVqWMOdxAe5kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>, stable@vger.kernel.org,
        security@kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52328 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1949160AbdDYPMw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 11:12:52 -0400
Content-Disposition: inline
In-Reply-To: <CAHmME9ovUDJRDA+Td4Y0bfQZEG5pZQo1JC0nYDVqWMOdxAe5kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-04-25, 17:08:28 +0200, Jason A. Donenfeld wrote:
> Hi Sabrina,
> 
> On Tue, Apr 25, 2017 at 4:53 PM, Sabrina Dubroca <sd@queasysnail.net> wrote:
> > Ugh, good catch :/
> >
> > AFAICT this patch doesn't really help, because NETIF_F_FRAGLIST
> > doesn't get tested in paths that can lead to triggering this.
> 
> You're right. This fixes the xmit() path, but not the receive path,
> which appears to take skbs directly from the upper device.
> 
> > I'll post a patch to allocate a properly-sized sg array.
> 
> I just posted this series, which should fix things in a robust way:
> 
> https://patchwork.ozlabs.org/patch/754861/

Yes, that prevents the overflow, but now you're just dropping
packets. I'll review that later, let's fix the overflow without
breaking connectivity for now.

-- 
Sabrina
