From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH] net: can: remove custom hex_to_bin()
Date: Mon, 18 Jul 2011 15:23:16 +0300
Message-ID: <1310991796.3903.6.camel@smile>
References: <1310977597-9666-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <201107182041.EHB78622.VOFSHFMOOFtLJQ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201107182041.EHB78622.VOFSHFMOOFtLJQ@I-love.SAKURA.ne.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-07-18 at 20:41 +0900, Tetsuo Handa wrote: 
> Andy Shevchenko wrote:
> >  	for (i = 0, dlc_pos++; i < cf.can_dlc; i++) {
> > -
> > -		tmp = asc2nibble(sl->rbuff[dlc_pos++]);
> > -		if (tmp > 0x0F)
> > +		tmp = hex_to_bin(sl->rbuff[dlc_pos++]);
> > +		if (tmp < 0)
> >  			return;
> >  		cf.data[i] = (tmp << 4);
> > -		tmp = asc2nibble(sl->rbuff[dlc_pos++]);
> > -		if (tmp > 0x0F)
> > +		tmp = hex_to_bin(sl->rbuff[dlc_pos++]);
> > +		if (tmp < 0)
> >  			return;
> >  		cf.data[i] |= tmp;
> >  	}
> 
> What about changing
> 
>   void hex2bin(u8 *dst, const char *src, size_t count)
> 
> to
> 
>   bool hex2bin(u8 *dst, const char *src, size_t count)
> 
> in order to do error checks like
> 
> bool hex2bin_with_validation(u8 *dst, const char *src, size_t count)
> {
> 	while (count--) {
> 		int c = hex_to_bin(*src++);
> 		int d;
> 		if (c < 0)
> 			return false;
> 		d = hex_to_bin(*src++)
> 		if (d < 0)
> 			return false;
> 		*dst++ = (c << 4) | d;
> 	}
> 	return true;
> }
> 
> and use hex2bin() rather than hex_to_bin()?
Perhaps, good idea. Could you submit a patch?

-- 
Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Intel Finland Oy
