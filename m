From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] net: can: remove custom hex_to_bin()
Date: Mon, 18 Jul 2011 20:41:14 +0900
Message-ID: <201107182041.EHB78622.VOFSHFMOOFtLJQ@I-love.SAKURA.ne.jp>
References: <1310977597-9666-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andriy.shevchenko@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1310977597-9666-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Shevchenko wrote:
>  	for (i = 0, dlc_pos++; i < cf.can_dlc; i++) {
> -
> -		tmp = asc2nibble(sl->rbuff[dlc_pos++]);
> -		if (tmp > 0x0F)
> +		tmp = hex_to_bin(sl->rbuff[dlc_pos++]);
> +		if (tmp < 0)
>  			return;
>  		cf.data[i] = (tmp << 4);
> -		tmp = asc2nibble(sl->rbuff[dlc_pos++]);
> -		if (tmp > 0x0F)
> +		tmp = hex_to_bin(sl->rbuff[dlc_pos++]);
> +		if (tmp < 0)
>  			return;
>  		cf.data[i] |= tmp;
>  	}

What about changing

  void hex2bin(u8 *dst, const char *src, size_t count)

to

  bool hex2bin(u8 *dst, const char *src, size_t count)

in order to do error checks like

bool hex2bin_with_validation(u8 *dst, const char *src, size_t count)
{
	while (count--) {
		int c = hex_to_bin(*src++);
		int d;
		if (c < 0)
			return false;
		d = hex_to_bin(*src++)
		if (d < 0)
			return false;
		*dst++ = (c << 4) | d;
	}
	return true;
}

and use hex2bin() rather than hex_to_bin()?
