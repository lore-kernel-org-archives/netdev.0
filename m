From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH] mt7601u: check memory allocation failure
Date: Mon, 21 Aug 2017 14:41:36 -0700
Message-ID: <20170821144136.477bf655@cakuba.netronome.com>
References: <20170821205956.20859-1-christophe.jaillet@wanadoo.fr>
        <20170821143430.635e4b92@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kvalo@codeaurora.org, matthias.bgg@gmail.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821143430.635e4b92@cakuba.netronome.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2017 14:34:30 -0700, Jakub Kicinski wrote:
> On Mon, 21 Aug 2017 22:59:56 +0200, Christophe JAILLET wrote:
> > Check memory allocation failure and return -ENOMEM in such a case, as
> > already done a few lines below
> > 
> > Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>  
> 
> Acked-by: Jakub Kicinski <kubakici@wp.pl>

Wait, I take that back.  This code is a bit weird.  We would return an
error, then mt7601u_dma_init() will call mt7601u_free_tx_queue() which
doesn't check for tx_q == NULL condition.

Looks like mt7601u_free_tx() has to check for dev->tx_q == NULL and
return early if that's the case.  Or mt7601u_alloc_tx() should really
clean things up on it's own on failure.  Ugh.
