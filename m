From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 16/26] net/sb1000: replace nicedelay() with ssleep()
Date: Wed, 9 Mar 2005 13:19:38 -0800
Message-ID: <20050309211938.GF3685@us.ibm.com>
References: <20050306103329.9BCC41E46E@trashy.coderock.org> <422F5B56.2030405@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: domen@coderock.org, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <422F5B56.2030405@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2005 at 03:23:50PM -0500, Jeff Garzik wrote:
> domen@coderock.org wrote:
> >Use ssleep() instead of nicedelay()
> >to guarantee the task delays as expected. Remove the prototype and
> >definition of nicedelay(). This is a very weird function, because it is
> >called to sleep in terms of usecs, but always sleeps for 1 second,
> >completely ignoring the parameter. I have gone ahead and followed suit,
> >just sleeping for a second in all cases, but maybe someone with the
> >hardware could tell me if perhaps the paramter *should* matter. 
> >Additionally,
> >nicedelay() is called in TASK_INTERRUPTIBLE state, but doesn't deal with 
> >signals
> >in case these longer delays do not complete, so I believe ssleep() is more
> >appropriate.
> >
> >Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> >Signed-off-by: Domen Puncer <domen@coderock.org>
> >---
> >
> >
> > kj-domen/drivers/net/sb1000.c |   14 +++-----------
> > 1 files changed, 3 insertions(+), 11 deletions(-)
> >
> >diff -puN drivers/net/sb1000.c~ssleep-drivers_net_sb1000 
> >drivers/net/sb1000.c
> >--- kj/drivers/net/sb1000.c~ssleep-drivers_net_sb1000	2005-03-05 
> >16:11:16.000000000 +0100
> >+++ kj-domen/drivers/net/sb1000.c	2005-03-05 16:11:16.000000000 +0100
> >@@ -90,7 +90,6 @@ static int sb1000_close(struct net_devic
> > 
> > 
> > /* SB1000 hardware routines to be used during open/configuration phases */
> >-static inline void nicedelay(unsigned long usecs);
> > static inline int card_wait_for_busy_clear(const int ioaddr[],
> > 	const char* name);
> > static inline int card_wait_for_ready(const int ioaddr[], const char* 
> > name,
> >@@ -254,13 +253,6 @@ static struct pnp_driver sb1000_driver =
> > 
> > const int TimeOutJiffies = (875 * HZ) / 100;
> > 
> >-static inline void nicedelay(unsigned long usecs)
> >-{
> >-	current->state = TASK_INTERRUPTIBLE;
> >-	schedule_timeout(HZ);
> >-	return;
> >-}
> >-
> > /* Card Wait For Busy Clear (cannot be used during an interrupt) */
> > static inline int
> > card_wait_for_busy_clear(const int ioaddr[], const char* name)
> >@@ -475,7 +467,7 @@ sb1000_reset(const int ioaddr[], const c
> > 	udelay(1000);
> > 	outb(0x0, port);
> > 	inb(port);
> >-	nicedelay(60000);
> >+	ssleep(1);
> > 	outb(0x4, port);
> > 	inb(port);
> > 	udelay(1000);
> >@@ -537,7 +529,7 @@ sb1000_activate(const int ioaddr[], cons
> > 	const unsigned char Command0[6] = {0x80, 0x11, 0x00, 0x00, 0x00, 
> > 	0x00};
> > 	const unsigned char Command1[6] = {0x80, 0x16, 0x00, 0x00, 0x00, 
> > 	0x00};
> > 
> >-	nicedelay(50000);
> >+	ssleep(1);
> > 	if ((status = card_send_command(ioaddr, name, Command0, st)))
> > 		return status;
> > 	if ((status = card_send_command(ioaddr, name, Command1, st)))
> >@@ -944,7 +936,7 @@ sb1000_open(struct net_device *dev)
> > 	/* initialize sb1000 */
> > 	if ((status = sb1000_reset(ioaddr, name)))
> > 		return status;
> >-	nicedelay(200000);
> >+	ssleep(1);
> 
> obviously incorrect, as you converted 60000, 50000, and 200000 usecs all 
> into "1 second".

Except that nicdelay() blatantly ignored the parameter. I asked several
times about this function and got no response. nicedelay() requests a
second delay currently, so I used ssleep().

Thanks,
Nish
