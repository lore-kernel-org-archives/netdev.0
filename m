From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH] batman-adv: Revert "use core MTU range checking in misc
 drivers"
Date: Sun, 23 Oct 2016 21:48:23 -0400
Message-ID: <20161024014823.GA42084@redhat.com>
References: <20161022074624.30033-1-sven@narfation.org>
 <20161023010826.GD32569@redhat.com>
 <2358358.cV5hCSMD7y@sven-edge>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        b.a.t.m.a.n@lists.open-mesh.org, linux-kernel@vger.kernel.org
To: Sven Eckelmann <sven@narfation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2358358.cV5hCSMD7y@sven-edge>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 23, 2016 at 09:17:50AM +0200, Sven Eckelmann wrote:
> On Samstag, 22. Oktober 2016 21:08:26 CEST Jarod Wilson wrote:
> [...]
> > You're going to
> > need more than just this revert though, since batman-adv calls
> > ether_setup, which will set min_mtu = 68, max_mtu = 1500, unless
> > batadv_hardif_min_mtu() always returns something 1500 or less.
> 
> It does only returns 1500 or less at the moment.
> 
>     return min_t(int, min_mtu - batadv_max_header_len(), ETH_DATA_LEN);
> 
> > Actually,
> > looking at that, you could omit the mtu < 68 bit from
> > batadv_interface_change_mtu() too, since that'll already get done in the
> > core, but I have no clue what you need for max_mtu.
> 
> I would like to get this revert through net-next.git before anything else.

Looks like that should work fine then.

-- 
Jarod Wilson
jarod@redhat.com
