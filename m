From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 01/12] lib: create common ascii hex array
Date: Tue, 13 May 2008 12:55:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805122218240.14152@wrl-59.cs.helsinki.fi>
References: <1210619134.24092.51.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	linux-scsi <linux-scsi@vger.kernel.org>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	linux-ide <linux-ide@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>, Ingo Molnar <mingo@elte.hu>,
	Jason Wessel <jason.wessel@windriver.com>,
	David Howells <dhowells@redhat.com>,
	"ralf@linux-mips.org" <ralf@linux-mips.org>,
	Paul Mundt <lethal@linux-sh.org>,
	Paul Mackerras <paulus@samba.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <1210619134.24092.51.camel@brick>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 May 2008, Harvey Harrison wrote:

> Add a common hex array in hexdump.c so everyone can use it.
> 
> Add a common hi/lo helper to avoid the shifting masking that is
> done to get the upper and lower nibbles of a byte value.
> 
> Pull the pack_hex_byte helper from kgdb as it is opencoded many
> places in the tree that will be consolidated.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> ---
>  
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 4d46e29..792bf0a 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -276,7 +276,17 @@ extern void print_hex_dump(const char *level, const char *prefix_str,
>  				const void *buf, size_t len, bool ascii);
>  extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
>  			const void *buf, size_t len);
> -#define hex_asc(x)	"0123456789abcdef"[x]
> +
> +extern const char hex_asc[];
> +#define hex_asc_lo(x)	hex_asc[((x) & 0x0f)]
> +#define hex_asc_hi(x)	hex_asc[((x) & 0xf0) >> 4]
> +
> +static inline char *pack_hex_byte(char *buf, u8 byte)
> +{
> +	*buf++ = hex_asc_hi(byte);
> +	*buf++ = hex_asc_lo(byte);
> +	return buf;
> +}

Any idea how much this will bloat kernel once it has, lets say 100 
users? 5k, 10k?


-- 
 i.
