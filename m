From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH] usb/mcs7830: Don't use buffers from stack for USB transfers
Date: Tue, 20 Jan 2009 23:50:21 +0100
Message-ID: <200901202350.23231.oliver@neukum.org>
References: <34115.192.168.0.40.1232483361.squirrel@server> <200901202345.47792.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Christian Eggers" <ceggers@gmx.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762006AbZATWuS@vger.kernel.org>
In-Reply-To: <200901202345.47792.arnd@arndb.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Tuesday 20 January 2009 23:45:47 schrieb Arnd Bergmann:
> Have you observed problems with this, or just suspected trouble?
> 
> When I wrote this code, I looked at other code doing the same
> and assumed it was ok, because usb_control_msg waits for the
> DMA to complete before returning.
> 
> Is the problem only on systems that have noncoherent DMA, or
> something else?

That's not enough. Tasks can leave pointers to variables on the
stack to other tasks. You must under no circumstances do DMA
on the stack if the driver may run on system that have noncoherent
DMA.

	Regards
		Oliver
