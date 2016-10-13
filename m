From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [mac80211] BUG_ON with current -git (4.8.0-11417-g24532f7)
Date: Thu, 13 Oct 2016 22:45:49 +0900
Message-ID: <20161013134549.GB583@swordfish>
References: <20161010150358.GA514@swordfish>
 <20161010153050.GA836@swordfish>
 <1476263106.5271.23.camel@sipsolutions.net>
 <20161012141245.GA436@swordfish>
 <1476282127.5271.30.camel@sipsolutions.net>
 <CALCETrXg9-OpJx5Rqz8afyaug+0DjzxvpdbOV9q6i01=zCZbcQ@mail.gmail.com>
 <1476338524.4904.1.camel@sipsolutions.net>
 <20161013134252.GA583@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@amacapital.net>,
        Johannes Berg <johannes@sipsolutions.net>,
        Andy Lutomirski <luto@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Wireless List <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>,
        "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Herbert Xu <herbert@gondor.apana.org.au>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:33013 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753133AbcJMOGd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 10:06:33 -0400
Content-Disposition: inline
In-Reply-To: <20161013134252.GA583@swordfish>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/13/16 22:42), Sergey Senozhatsky wrote:
> 
> On (10/13/16 08:02), Johannes Berg wrote:
> > On Wed, 2016-10-12 at 22:39 -0700, Andy Lutomirski wrote:
> > 
> > > In a pinch, I have these patches sitting around:
> > > 
> > > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=x86/vmap_stack&id=0a39cfa6fbb5d5635c85253cc7d6b44b54822afd
> > > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/commit/?h=x86/vmap_stack&id=bf8cfa200b5a01383ea39fc8ce2f32909767baa8
> > 
> > That truly sounds like something we'd rather avoid in the TX/RX paths
> > though, which should perform well.
> 
> didn't fix.
> 
> so I finally had some time to do a better bug-reporter job.
> 
> I added a bunch of printk-s and several virt_addr_valid()-s
> to ieee80211_aes_ccm_encrypt().
> 
> and right befoe the Oops I see the following report from
> virt_addr_valid()
> 
> 
>  FAIL: 00004100002cba02 > ffffc900802cba02 || 1 -> (00004100002cba02 >> 39) == 130

that  `(00004100002cba02 >> 39) == 130'   part is

phys_addr_valid()
{
	(addr >> boot_cpu_data.x86_phys_bits)
}

	-ss
