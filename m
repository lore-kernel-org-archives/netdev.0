From: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Subject: Re: [Bluez-devel] forcing SCO connection patch
Date: Tue, 26 Feb 2008 04:07:27 +0100
Message-ID: <70692DDF-93B7-447E-ABEE-3CDBD94F15F1@holtmann.org>
References: <47666E1F.2000902@mizi.com>	 <a8e1da0802242330l765b8b1ava62b857baf8a5568@mail.gmail.com>	 <47C28A33.4070102@mizi.com> <a8e1da0802250155u1b7af481va203849f68d9106b@mail.gmail.com> <47C2A7FA.2060902@mizi.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bmidgley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <47C2A7FA.2060902-6CAt/Z4uMM0@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Louis,

> I fixed all of errors except 80 characters warning.
> Thanks
>
> Louis JANG
>
> Signed-off-by: Louis JANG <louis-6CAt/Z4uMM0@public.gmane.org>
>
> --- linux-2.6.23/net/bluetooth/hci_event.c.orig	2008-02-25  
> 17:17:11.000000000 +0900
> +++ linux-2.6.23/net/bluetooth/hci_event.c	2008-02-25  
> 17:30:23.000000000 +0900
> @@ -1313,8 +1313,17 @@
> 	hci_dev_lock(hdev);
>
> 	conn = hci_conn_hash_lookup_ba(hdev, ev->link_type, &ev->bdaddr);
> -	if (!conn)
> -		goto unlock;
> +	if (!conn) {
> +		if (ev->link_type != ACL_LINK) {
> +			__u8 link_type = (ev->link_type == ESCO_LINK) ? SCO_LINK :  
> ESCO_LINK;
> +
> +			conn = hci_conn_hash_lookup_ba(hdev, link_type, &ev->bdaddr);
> +			if (conn)
> +				conn->type = ev->link_type;
> +		}
> +		if (!conn)
> +			goto unlock;
> +	}

NAK. There is no need to check for ACL_LINK. The sync_complete will  
only be called for SCO or eSCO connections.

> diff -uNr linux-2.6.23/include/net/bluetooth-orig/sco.h linux-2.6.23/ 
> include/net/bluetooth/sco.h
> --- linux-2.6.23/include/net/bluetooth-orig/sco.h	2007-10-10  
> 05:31:38.000000000 +0900
> +++ linux-2.6.23/include/net/bluetooth/sco.h	2008-02-25  
> 18:04:20.000000000 +0900
> @@ -51,6 +51,8 @@
> 	__u8  dev_class[3];
> };
>
> +#define SCO_FORCESCO	0x03
> +

NAK. We don't need this. And even if we really would want this, we  
would do it via extra parameters inside sockaddr_sco. In that case we  
would do it right and exposing eSCO settings and not some boolean  
parameter.

Regards

Marcel

-
To unsubscribe from this list: send the line "unsubscribe linux-bluetooth" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
