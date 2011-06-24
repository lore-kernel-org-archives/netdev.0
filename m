From: James Carlson <carlsonj@workingcode.com>
Subject: Re: ppp_deflate + kmalloc
Date: Fri, 24 Jun 2011 10:02:40 -0400
Message-ID: <4E049900.4080402@workingcode.com>
References: <BANLkTi=+2dqr1LPwG8MHpcYOyzJH57iavw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulus@samba.org, linux-ppp@vger.kernel.org, netdev@vger.kernel.org
To: Martin Jackson <mjackson220.list@gmail.com>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=+2dqr1LPwG8MHpcYOyzJH57iavw@mail.gmail.com>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Jackson wrote:
> In our android froyo-based system (omap3 hardware), we are getting the
> following problem where the ppp driver cannot kmalloc enough memory
> for the decomp buffer in the ppp driver.
> 
> Trying to make a 4th-order kmalloc (I think that amounts to 64kB)
> seems ambitious. I do not understand why vmalloc is not being used
> here, like it is for the compression buffer. Is using vmalloc here an
> acceptable solution?

The code here shouldn't need contiguous pages, so vmalloc (even if
"slower") shouldn't be a problem.

But a higher-level question might be why you're bothering with RFC 1979
Deflate compression at all on this platform.  I'd expect that you're
most likely going to end up talking to commercially-produced PPP servers
(possibly 3GPP or similar) at the other end, and very, very few of them
offer data compression with either RFC 1977 (BSD Compression) or RFC
1979.  ("Very, very few" is probably being generous ...)

If it's always going to be negotiated away in practice, and if you're
having trouble with memory constraints, why not just ditch the baggage?

-- 
James Carlson         42.703N 71.076W         <carlsonj@workingcode.com>
