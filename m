From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/10] crc-itu-t: add bit-reversed calculation
Date: Wed, 3 Jun 2009 17:05:06 -0700
Message-ID: <20090603170506.a10cc38f.akpm@linux-foundation.org>
References: <1243868091-5315-1-git-send-email-dbaryshkov@gmail.com>
	<1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, slapin@ossfans.org,
	maxim.osipov@siemens.com, dmitry.baryshkov@siemens.com,
	oliver.fendt@siemens.com, linux@youmustbejoking.demon.co.uk
To: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:53452 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752104AbZFDAFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 20:05:21 -0400
In-Reply-To: <1243868091-5315-2-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  1 Jun 2009 18:54:42 +0400
Dmitry Eremin-Solenikov <dbaryshkov@gmail.com> wrote:

> From: Darren Salt <linux@youmustbejoking.demon.co.uk>
> 
> ..
>
>  static inline u16 crc_itu_t_byte(u16 crc, const u8 data)
>  {
>  	return (crc << 8) ^ crc_itu_t_table[((crc >> 8) ^ data) & 0xff];
>  }
>  
> +static inline u16 crc_itu_t_bitreversed_byte(u16 crc, const u8 data)
> +{
> +	return (crc << 8) ^ crc_itu_t_table[((crc >> 8) ^ bitrev8(data)) & 0xff];
> +}

I suspect that inlining these was a mistake, but one which we make often.

>  #endif /* CRC_ITU_T_H */
>  
> diff --git a/lib/crc-itu-t.c b/lib/crc-itu-t.c
> index a63472b..5562fdd 100644
> --- a/lib/crc-itu-t.c
> +++ b/lib/crc-itu-t.c
> @@ -64,6 +64,24 @@ u16 crc_itu_t(u16 crc, const u8 *buffer, size_t len)
>  }
>  EXPORT_SYMBOL(crc_itu_t);
>  
> +/**
> + * crc_itu_t_bitreversed - Compute the CRC-ITU-T for the data buffer;
> + * the buffer content is assumed to be bit-reversed

kerneldoc doesn't support the breaking of this information across
multiple lines.  It'll need to be done as a single 120-column line.


> + * @crc:     previous CRC value
> + * @buffer:  data pointer
> + * @len:     number of bytes in the buffer
> + *
> + * Returns the updated CRC value
> + */
> +u16 crc_itu_t_bitreversed(u16 crc, const u8 *buffer, size_t len)
> +{
> +	while (len--)
> +		crc = crc_itu_t_bitreversed_byte(crc, *buffer++);
> +	return crc;
> +}
> +EXPORT_SYMBOL(crc_itu_t_bitreversed);

