From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 9 Feb 2007 20:26:42 +0100
Message-ID: <200702092026.43006.mb@bu3sch.de>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <200702091945.25187.mb@bu3sch.de> <45CCC8B5.3060108@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
To: Joseph Jezak <josejx-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <45CCC8B5.3060108-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 09 February 2007 20:17, Joseph Jezak wrote:
> > 
> > The specs are unclear at this point:
> > "Write the value to the offset"
> > Offset in which register type?
> 
> PHY Register.  I've clarified it in the specs, I think this was said 
> before, I made it worse when I cleaned it up.
> 
> >>  	// Initialization
> >> -	if (phy->version == 0) {
> >> +	if (phy->analog == 0) {
> >>  		bcm43xx_write16(bcm, 0x03E6, 0x0122);
> >>  	} else {
> >> -		if (phy->version >= 2)
> >> -			bcm43xx_write16(bcm, 0x03E6, 0x0040);
> >> +		if (phy->analog >= 2)
> >> +			bcm43xx_write16(bcm, 0x0003, (bcm43xx_read16(bcm, 0x0003)
> >> +					& 0xFFBF) | 0x0040);
> > 
> > I think here is a specs bug.
> 
> This is correct.  Why do you think it's a specs bug?

Because
a) The old one made more sense to me.
b) Write MMIO register 0x3? I mean. What is that?
   Could this be PHY or radio register 0x3?

-- 
Greetings Michael.
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
