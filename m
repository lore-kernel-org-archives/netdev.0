From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next 3/5] packet: minor: convert status bits into
 shifting format
Date: Tue, 23 Apr 2013 08:22:07 -0400
Message-ID: <CA+FuTSfKaeqGCefRRfZp2fCJnr2ca4Y1sFXVNpB02g3fw3TtVA@mail.gmail.com>
References: <1366713572-11978-1-git-send-email-dborkman@redhat.com> <1366713572-11978-4-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Chavent <Paul.Chavent@onera.fr>,
	Richard Cochran <richardcochran@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:52294 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755000Ab3DWMWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 08:22:37 -0400
Received: by mail-ie0-f178.google.com with SMTP id aq17so587954iec.9
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 05:22:37 -0700 (PDT)
In-Reply-To: <1366713572-11978-4-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 6:39 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> This makes it more readable and clearer what bits are still free to
> use. The compiler reduces this to a constant for us anyway.
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Acked-by: Willem de Bruijn <willemb@google.com>
> ---
>  This is just to bring the status bits' format in line with the
>  next patch.

This change is not strictly necessary on its own, but it does make
it easier to verify the high bits used in the next patch.

>  include/uapi/linux/if_packet.h | 22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
>
> diff --git a/include/uapi/linux/if_packet.h b/include/uapi/linux/if_packet.h
> index 8136658..4dfc234 100644
> --- a/include/uapi/linux/if_packet.h
> +++ b/include/uapi/linux/if_packet.h
> @@ -86,19 +86,19 @@ struct tpacket_auxdata {
>  };
>
>  /* Rx ring - header status */
> -#define TP_STATUS_KERNEL       0x0
> -#define TP_STATUS_USER         0x1
> -#define TP_STATUS_COPY         0x2
> -#define TP_STATUS_LOSING       0x4
> -#define TP_STATUS_CSUMNOTREADY 0x8
> -#define TP_STATUS_VLAN_VALID   0x10 /* auxdata has valid tp_vlan_tci */
> -#define TP_STATUS_BLK_TMO      0x20
> +#define TP_STATUS_KERNEL             0
> +#define TP_STATUS_USER         (1 << 0)
> +#define TP_STATUS_COPY         (1 << 1)
> +#define TP_STATUS_LOSING       (1 << 2)
> +#define TP_STATUS_CSUMNOTREADY (1 << 3)
> +#define TP_STATUS_VLAN_VALID   (1 << 4) /* auxdata has valid tp_vlan_tci */
> +#define TP_STATUS_BLK_TMO      (1 << 5)
>
>  /* Tx ring - header status */
> -#define TP_STATUS_AVAILABLE    0x0
> -#define TP_STATUS_SEND_REQUEST 0x1
> -#define TP_STATUS_SENDING      0x2
> -#define TP_STATUS_WRONG_FORMAT 0x4
> +#define TP_STATUS_AVAILABLE          0
> +#define TP_STATUS_SEND_REQUEST (1 << 0)
> +#define TP_STATUS_SENDING      (1 << 1)
> +#define TP_STATUS_WRONG_FORMAT (1 << 2)
>
>  /* Rx ring - feature request bits */
>  #define TP_FT_REQ_FILL_RXHASH  0x1
> --
> 1.7.11.7
>
