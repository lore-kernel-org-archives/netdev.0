From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 1/4] drivers/net/ethernet/sfc: Add efx_ prefix to set_bit_le()
Date: Mon, 11 Jun 2012 14:09:15 +0000
Message-ID: <201206111409.16093.arnd@arndb.de>
References: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp> <20120611212901.2b4d0a17.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, grundler@parisc-linux.org,
	avi@redhat.com, mtosatti@redhat.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org, takuya.yoshikawa@gmail.com
To: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120611212901.2b4d0a17.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 11 June 2012, Takuya Yoshikawa wrote:
> 
>  /* Set bit in a little-endian bitfield */
> -static inline void set_bit_le(unsigned nr, unsigned char *addr)
> +static inline void efx_set_bit_le(unsigned nr, unsigned char *addr)
>  {
>         addr[nr / 8] |= (1 << (nr % 8));
>  }
>  
>  /* Clear bit in a little-endian bitfield */
> -static inline void clear_bit_le(unsigned nr, unsigned char *addr)
> +static inline void efx_clear_bit_le(unsigned nr, unsigned char *addr)
>  {
>         addr[nr / 8] &= ~(1 << (nr % 8));
>  }

Hmm, any reason why we're not just using the existing non-atomic
__set_bit_le() here? I think the helpers in sfc and tulip can
just get removed if you use those.

	Arnd
