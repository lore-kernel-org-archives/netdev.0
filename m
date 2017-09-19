From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [RFC PATCH 3/3] usbnet: Fix memory leak when rx_submit() fails
Date: Tue, 19 Sep 2017 19:41:09 +0200
Message-ID: <877ewuoabu.fsf@miraculix.mork.no>
References: <20170919161522.995-1-dianders@chromium.org>
        <20170919161522.995-3-dianders@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: Oliver Neukum <oneukum@suse.com>, groeck@chromium.org,
        grundler@chromium.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Douglas Anderson <dianders@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919161522.995-3-dianders@chromium.org> (Douglas Anderson's
        message of "Tue, 19 Sep 2017 09:15:22 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Douglas Anderson <dianders@chromium.org> writes:

> If rx_submit() returns an error code then nobody calls usb_free_urb().
> That means it's leaked.

Nope.  rx_submit() will call usb_free_urb() before returning an error:


static int rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
..
	if (!skb) {
		netif_dbg(dev, rx_err, dev->net, "no rx skb\n");
		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
		usb_free_urb (urb);
		return -ENOMEM;
	}
..
	if (retval) {
		dev_kfree_skb_any (skb);
		usb_free_urb (urb);
	}





Bj=C3=B8rn
