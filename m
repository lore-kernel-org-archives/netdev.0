From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH] bluetooth: 6lowpan: fix use after free in
 chan_suspend/resume
Date: Fri, 31 Mar 2017 12:10:27 +0200
Message-ID: <2B4AB0D3-D55D-4F3F-ACA6-F82DC680316E@holtmann.org>
References: <20170329061018.4243-1-michael.scott@linaro.org>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
        Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
        linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Scott <michael.scott-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170329061018.4243-1-michael.scott-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Michael,

> A status field in the skb_cb struct was storing a channel status
> based on channel suspend/resume events.  This stored status was
> then used to return EAGAIN if there were packet sending issues
> in snd_pkt().
> 
> The issue is that the skb has been freed by the time the callback
> to 6lowpan's suspend/resume was called.  So, this generates a
> "use after free" issue that was noticed while running kernel tests
> with KASAN debug enabled.
> 
> Let's eliminate the status field entirely as we can use the channel
> tx_credits to indicate whether we should return EAGAIN when handling
> packets.
> 
> Signed-off-by: Michael Scott <michael.scott-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
> net/bluetooth/6lowpan.c | 21 +++------------------
> 1 file changed, 3 insertions(+), 18 deletions(-)

patch has been applied to bluetooth-next tree.

Regards

Marcel
