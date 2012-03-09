From: Johan Hovold <jhovold@gmail.com>
Subject: Re: [PATCH 2/3] bluetooth: hci_ldisc: fix NULL-pointer dereference
 on tty_close
Date: Fri, 9 Mar 2012 16:50:07 +0100
Message-ID: <20120309155007.GI4497@localhost>
References: <1331307806-21761-1-git-send-email-jhovold@gmail.com>
 <1331307806-21761-3-git-send-email-jhovold@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	stable <stable@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>
To: David Herrmann <dh.herrmann@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331307806-21761-3-git-send-email-jhovold@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 09, 2012 at 04:43:25PM +0100, Johan Hovold wrote:
> Do not close protocol driver until device has been unregistered.
> 
> This fixes a race between tty_close and hci_dev_open which can result in
> a NULL-pointer dereference.
> 
> The line discipline closes the protocol driver while we may still have
> hci_dev_open sleeping on the req_lock mutex resulting in a NULL-pointer
> dereference when lock is acquired and hci_init_req called.

[...]

> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Johan Hovold <jhovold@gmail.com>

David (Herrmann), I forgot to add your Reviewed-by on this one. Feel
free to add it again if you want to.

Thanks,
Johan

> ---
>  drivers/bluetooth/hci_ldisc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
> index 97c5faa..5119c4b 100644
> --- a/drivers/bluetooth/hci_ldisc.c
> +++ b/drivers/bluetooth/hci_ldisc.c
> @@ -309,11 +309,11 @@ static void hci_uart_tty_close(struct tty_struct *tty)
>  			hci_uart_close(hdev);
>  
>  		if (test_and_clear_bit(HCI_UART_PROTO_SET, &hu->flags)) {
> -			hu->proto->close(hu);
>  			if (hdev) {
>  				hci_unregister_dev(hdev);
>  				hci_free_dev(hdev);
>  			}
> +			hu->proto->close(hu);
>  		}
>  		kfree(hu);
>  	}
