From: Roger Luethi <rl@hellgate.ch>
Subject: Re: [6/9][PATCH 2.6] Fix Tx engine race for good
Date: Sun, 20 Jun 2004 00:18:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040619221837.GC3313@k3.hellgate.ch>
References: <20040615174933.GA11294@k3.hellgate.ch> <40D4AEA4.6050005@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <40D4AEA4.6050005@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 19 Jun 2004 17:22:44 -0400, Jeff Garzik wrote:
> Roger Luethi wrote:
> >+#define RHINE_WAIT_FOR(condition) do {				 \
> >+	int i=1024;							\
> >+	while (!(condition) && --i)					\
> >+		;							\
> >+	if (debug > 1 && i < 512)					\
> >+		printk(KERN_INFO "%s: %4d cycles used @ %s:%d\n",	\
> >+				DRV_NAME, 1024-i, __func__, __LINE__);	\
> >+} while(0)
> 
> empty loops need at least a cpu_relax(), if not a true delay to 
> guarantee the timing you desire.

Sure, I can add a cpu_relax(). FWIW, though, this macro is only used
for one purpose: Waiting for registers to reach a certain value. IOW:
Every evaluation of "condition" causes an I/O operation (inb or readb).

> Also, it would be nice to change the name, since there isn't anything 
> rhine-specific about this macro.

Hmm... It relies on DRV_NAME :-). It's trivial to write a more generic
version if there's interest. I'm just trying to keep the namespace
clean. ... I just checked: drivers/macintosh/via-cuda.c defines a macro
WAIT_FOR that does pretty much the same. Does that already make the
case for a generic function for everyone to use?

Roger
