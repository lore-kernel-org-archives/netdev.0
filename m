From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2] drivers/net/usb/hso.c: prevent reading
 uninitialized memory
Date: Thu, 16 Sep 2010 13:36:25 -0400
Message-ID: <1284658585.23787.43.camel@gandalf.stny.rr.com>
References: <1284587008.6275.95.camel@dan>
	 <20100916155745.GB14318@home.goodmis.org>
	 <20100916180710.07821bdd@lxorguk.ukuu.org.uk>
	 <1284655960.23787.34.camel@gandalf.stny.rr.com>
	 <20100916184735.1699492e@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, j.dumon@option.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	security@kernel.org, davem@davemloft.net, stable@kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100916184735.1699492e@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-16 at 18:47 +0100, Alan Cox wrote:

> If you want to micro-optimise it you can enumerate the cases that
> tiocmget can be NULL in that driver..

Heh, I think that's going a bit too far. Of course mico-optimizations
usually make the system go faster, but not enough to show out of the
noise, and micro-optimizations most of the time just make the code
harder to understand and more error prone.

A lot of the patches in this patch set could just do the:

	struct foo bar = { 0 };

This would let gcc optimize what needs to be done, and avoids a function
call to memset.

-- Steve
