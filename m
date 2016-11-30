From: Zefir Kurtisi <zefir.kurtisi@neratec.com>
Subject: Re: [patch net / RFC] net: fec: increase frame size limitation to
 actually available buffer
Date: Wed, 30 Nov 2016 17:05:09 +0100
Message-ID: <05a7c0a7-b680-af75-963b-5cddeda7f2c4@neratec.com>
References: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Chris Healy <cphealy@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        linux-kernel@vger.kernel.org
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        "David S. Miller" <davem@davemloft.net>,
        Fugang Duan <fugang.duan@nxp.com>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.neratec.com ([46.140.151.2]:8895 "EHLO mail.neratec.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757167AbcK3QFM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 11:05:12 -0500
In-Reply-To: <1480444528-30054-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/29/2016 07:35 PM, Nikita Yushchenko wrote:
> Fec driver uses Rx buffers of 2k, but programs hardware to limit
> incoming frames to 1522 bytes. This raises issues when FEC device
> is used with DSA (since DSA tag can make frame larger), and also
> disallows manual sending and receiving larger frames.
> 
> This patch removes the limitation, allowing Rx size up to entire buffer.
> At the same time possible Tx size is increased as well, because hardware
> uses the same register field to limit Rx and Tx.
> 
> Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
> ---

I recently did similar changes to the freescale/gianfar to prevent fragmentation
of (E)DSA frames [1].

With the fragmentation kicking in, I noticed a bug in the scatter-gather logic
which caused the frame-size of fragmented frames to be reported wrong [2]. Not
sure if the fec driver has SG capabilities and if this issue also applies, you
might want to double-check.


Cheers,
Zefir


[1] http://marc.info/?l=linux-netdev&m=147187438313519&w=2
[2] http://marc.info/?l=linux-netdev&m=147187430213484&w=2
