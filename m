From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 2/2] hso: fix deadlock when receiving bursts of data
Date: Mon, 14 Jul 2014 19:27:58 -0700 (PDT)
Message-ID: <20140714.192758.1087918241017989929.davem@davemloft.net>
References: <1405332530-2507-1-git-send-email-olivier@sobrie.be>
	<1405332530-2507-2-git-send-email-olivier@sobrie.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org,
	gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org
To: olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1405332530-2507-2-git-send-email-olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
Date: Mon, 14 Jul 2014 12:08:50 +0200

> When the module sends bursts of data, sometimes a deadlock happens in
> the hso driver when the tty buffer doesn't get the chance to be flushed
> quickly enough.
> 
> Remove the endless while loop in function put_rxbuf_data() which is
> called by the urb completion handler.
> If there isn't enough room in the tty buffer, discards all the data
> received in the URB.
> 
> Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Cc: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
> Cc: One Thousand Gnomes <gnomes-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
> Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: Jan Dumon <j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Olivier Sobrie <olivier-Ui3EtX6WB9GzQB+pC5nmwQ@public.gmane.org>
> ---
> Changes in v2:
>  - remove the unthrottle timer added in the previous patch version
>  - drop entire rx urb data if there is not enough space in tty buffer
>  - remove variable curr_rx_urb_offset from hso_serial structure

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
