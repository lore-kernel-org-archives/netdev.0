From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/4] bas_gigaset: collapse CR/LF at end of AT response
Date: Wed, 24 Feb 2010 08:43:30 +1100
Message-ID: <20100223214329.GA5801@verge.net.au>
References: <20100221-patch-gigaset-00.tilman@imap.cc>
 <20100221-patch-gigaset-02.tilman@imap.cc>
 <20100223063425.GA28744@verge.net.au>
 <4B83D5D7.3040407@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B83D5D7.3040407@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2010 at 02:19:19PM +0100, Tilman Schmidt wrote:
> Simon Horman schrieb:
> > I am confused about what the value of MAX_RESP_SIZE means.
> > Is it a hw restriction?
> 
> It's an arbitrary limitation in the driver. The hardware specification
> says nothing about the possible length of AT responses from the device,
> so we had to draw a line somewhere. 512 bytes have so far proved to be
> amply sufficient.
> 
> In practice, the limit is only hit with the M10x devices (which transmit
> commands and data over the same channel) when the state machine gets out
> of sync and tries to interpret received payload data as AT responses.

Ok, understood. Thanks for the clarification.

> > It seems that up to MAX_RESP_SIZE of string-data is permitted if the line
> > is terminated by CR. But only MAX_RESP_SIZE -1  bytes if the line is
> > terminated by LF or CR LF.
> 
> Note that when storing the CR in cs->respdata[0] for possible collapsing
> with a subsequent LF, the cbytes counter is left at 0, so the CR gets
> overwritten by the first character of the next response if there's no
> intervening LF.

Yes, I had to look at that for quite a while :-)
