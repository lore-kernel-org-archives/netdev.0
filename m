From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v1] USBNET: fix handling padding packet
Date: Sat, 28 Sep 2013 07:51:32 +0800
Message-ID: <CACVXFVNrv9i-0TnBbL++Tc50digGAKfuPD0cW2T7M-kB+AciMQ@mail.gmail.com>
References: <1379941175-10500-1-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1379941175-10500-1-git-send-email-ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 23, 2013 at 8:59 PM, Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> wrote:
> Commit 638c5115a7949(USBNET: support DMA SG) introduces DMA SG
> if the usb host controller is capable of building packet from
> discontinuous buffers, but missed handling padding packet when
> building DMA SG.
>
> This patch attachs the pre-allocated padding packet at the
> end of the sg list, so padding packet can be sent to device
> if drivers require that.
>
> Reported-by: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
> Acked-by: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
> Signed-off-by: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> ---
> v1:
>         - fix bug in case of dev->can_dma_sg and !urb->num_sgs

David, could you queue this patch in your tree? And it should fix
regression caused by commit 638c5115a7949(USBNET: support
DMA SG), since I found that without the padding the device can't
send out packets successfully if their length is dividable by max
packet size, and the problem can be observed with icmp sending:

 $ping -s 974 another_machine  #from host with ax99179_178a attached


Thanks,
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
