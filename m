From: Joe Perches <joe@perches.com>
Subject: Re: [RESEND PATCH 0/2] Make functions of dev_<level> macros,
 recursive vsnprintf
Date: Sat, 06 Mar 2010 14:30:54 -0800
Message-ID: <1267914654.849.81.camel@Joe-Laptop.home>
References: <cover.1267682641.git.joe@perches.com>
	 <20100304143837.af39845d.akpm@linux-foundation.org>
	 <alpine.LFD.2.00.1003041504080.3751@localhost.localdomain>
	 <1267911399.849.39.camel@Joe-Laptop.home>
	 <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Nick Andrew <nick@nick-andrew.net>,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.00.1003061356420.31447@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-03-06 at 14:03 -0800, Linus Torvalds wrote:
> On Sat, 6 Mar 2010, Joe Perches wrote:
> > Is that an ack, a nack or a get the hell out?
> It's mostly an Ack. I think the concept is great. I'd love to have some 
> way to limit recursion,

Maybe limit the %pV recursion depth to 1 with something like:
(in vsprintf.c: pointer() )

	case 'V': {
		char *rtn;
		static int rcount++;

		if (rcount > 1) {	/* Don't recurse more than once */
			rcount--;
			break;		/* Use print the pointer */
		}
		rtn = buf + vsnprintf(buf, end - buf,
				      ((struct va_format *)ptr)->fmt,
				      *(((struct va_format *)ptr)->va));
		rcount--;
		return rtn;
	}
	
> and I'd also love to see some actual numbers of 
> how deep the vsnprintf stack frame is, but I don't see how to do the 
> first, and I'm hoping the second isn't too horrible.

I believe it's the arguments, a long long, a couple of pointers,
and a struct printf_spec.  Not too bad.
