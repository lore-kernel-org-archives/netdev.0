From: Emmanuel Grumbach <egrumbach-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/2] iwlwifi: pcie: allow to build an A-MSDU using TSO core
Date: Mon, 26 Oct 2015 20:21:36 +0200
Message-ID: <CANUX_P2oE8Hb5s68simRfJyPL+JQOhmvpyOi87zzCoW5mVjOuQ@mail.gmail.com>
References: <1445533095-15608-1-git-send-email-emmanuel.grumbach@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Sharon, Sara" <sara.sharon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Ido Yariv <ido-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
To: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1445533095-15608-1-git-send-email-emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Eric,

>
> When the op_mode sends an skb whose payload is bigger than
> MSS, PCIe will create an A-MSDU out of it. PCIe assumes
> that the skb that is coming from the op_mode can fit in one
> A-MSDU. It is the op_mode's responsibility to make sure
> that this guarantee holds.
>
> Additional headers need to be built for the subframes.
> The TSO core code takes care of the IP / TCP headers and
> the driver takes care of the 802.11 subframe headers.
>
> These headers are stored on a per-cpu page that is re-used
> for all the packets handled on that same CPU. Each skb
> holds a reference to that page and releases the page when
> it is reclaimed. When the page gets full, it is released
> and a new one is allocated.
>
> Since any SKB that doesn't go through the fast-xmit path
> of mac80211 will be segmented, we can assume here that the
> packet is not WEP / TKIP and has a proper SNAP header.
>
> Signed-off-by: Emmanuel Grumbach <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Assuming your review queue works as a FIFO and you reviewed the TSO
helper patch, I can assume you ACK this one? :)
Or at least, don't NACK it :)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
