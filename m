From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: make allyesconfig i386 build failure with next-20150122 (caused
 by fb_agm1264k-fl driver)
Date: Mon, 26 Jan 2015 13:59:59 -0800
Message-ID: <20150126215959.GA9853@roeck-us.net>
References: <CA+r1ZhhXF+hicy7JKo3jAbgSbO4KOLm6BwPosTKNb+E_Cb4yPQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next <linux-next@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel <devel@driverdev.osuosl.org>, isdn@linux-pingi.de,
	netdev <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Jim Davis <jim.epost@gmail.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+r1ZhhXF+hicy7JKo3jAbgSbO4KOLm6BwPosTKNb+E_Cb4yPQ@mail.gmail.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 22, 2015 at 12:10:33PM -0700, Jim Davis wrote:
> make ARCH=i386 allyesconfig fails with
> 
> drivers/staging/built-in.o: In function `reset':
> (.text+0x2ae89d): multiple definition of `reset'
> drivers/isdn/built-in.o:(.text+0x185dc2): first defined here
> make[1]: *** [drivers/built-in.o] Error 1

Culprit:

commit b2ebd4be6fa1d2329b63531b044f9e25474981cb
Author: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date:   Wed Dec 31 10:11:10 2014 +0100

    staging: fbtft: add fb_agm1264k-fl driver

A global function named 'reset' isn't really a good idea.

Not that the global function with the same name in the isdn code
is better ;-).

Guenter
