From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: Re: [PATCH] mt7601u: check memory allocation failure
Date: Tue, 22 Aug 2017 00:08:54 +0200
Message-ID: <f8db0e55-8480-ea91-e54a-1c83e7ff64a9@wanadoo.fr>
References: <20170821205956.20859-1-christophe.jaillet@wanadoo.fr>
 <20170821143430.635e4b92@cakuba.netronome.com>
 <20170821144136.477bf655@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: kvalo@codeaurora.org, matthias.bgg@gmail.com,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170821144136.477bf655@cakuba.netronome.com>
Content-Language: fr
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 21/08/2017 à 23:41, Jakub Kicinski a écrit :
> On Mon, 21 Aug 2017 14:34:30 -0700, Jakub Kicinski wrote:
>> On Mon, 21 Aug 2017 22:59:56 +0200, Christophe JAILLET wrote:
>>> Check memory allocation failure and return -ENOMEM in such a case, as
>>> already done a few lines below
>>>
>>> Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
>> Acked-by: Jakub Kicinski <kubakici@wp.pl>
> Wait, I take that back.  This code is a bit weird.  We would return an
> error, then mt7601u_dma_init() will call mt7601u_free_tx_queue() which
> doesn't check for tx_q == NULL condition.
>
> Looks like mt7601u_free_tx() has to check for dev->tx_q == NULL and
> return early if that's the case.  Or mt7601u_alloc_tx() should really
> clean things up on it's own on failure.  Ugh.
>
You are right. Thanks for the review.

I've sent a v2 which updates 'mt7601u_free_tx()'.
Doing so sounds more in line with the spirit of this code.

CJ
