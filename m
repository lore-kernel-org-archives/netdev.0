From: David Miller <davem@davemloft.net>
Subject: Re: SCTP checksum patch for 2.6.26.5
Date: Mon, 22 Sep 2008 13:12:45 -0700 (PDT)
Message-ID: <20080922.131245.193705447.davem@davemloft.net>
References: <48D7C0A2.9090406@protei.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: nickolay@protei.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44693
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751313AbYIVUM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 16:12:57 -0400
In-Reply-To: <48D7C0A2.9090406@protei.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nickolay Vinogradov <nickolay@protei.ru>
Date: Mon, 22 Sep 2008 19:58:26 +0400

CC:'ing correct mailing lists...

> SCTP checksum calculation fix for BigEndian.
> ntohl() doesn't do anything on BigEndian.
> 
> diff --git a/Makefile b/Makefile
> diff --git a/include/net/sctp/checksum.h b/include/net/sctp/checksum.h
> index ba75c67..2f0ed64 100644
> --- a/include/net/sctp/checksum.h
> +++ b/include/net/sctp/checksum.h
> @@ -74,5 +74,19 @@ static inline __u32 sctp_update_cksum(__u8 *buffer, __u16 length, __u32 crc32)
> 
>   static inline __u32 sctp_end_cksum(__u32 crc32)
>   {
> -       return ntohl(~crc32);
> +       __u32 result;
> +       __u8 byte0, byte1, byte2, byte3;
> +
> +       result = ~crc32;
> +
> +       byte0 = result & 0xff;
> +       byte1 = (result>>8) & 0xff;
> +       byte2 = (result>>16) & 0xff;
> +       byte3 = (result>>24) & 0xff;
> +
> +       crc32 = ((byte0 << 24) |
> +                (byte1 << 16) |
> +                (byte2 << 8)  |
> +                byte3);
> +       return crc32;
>   }
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> 
> 
> -- Nickolay Vinogradov
> Protei Research and Development Center
> St.Petersburg, 194044, Russia
> Tel.: +7 812 449 47 27
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
