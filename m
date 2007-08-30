From: Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] Don't needlessly initialize variable to NULL in zd_chip   (was: Re: [PATCH 13/30] net: Don't do pointless kmalloc return value casts in zd1211 driver)
Date: Fri, 31 Aug 2007 00:30:31 +0200
Message-ID: <200708310030.31713.jesper.juhl@gmail.com>
References: <1554af80879a7ef2f78a4d654f23c248203500d9.1187912217.git.jesper.juhl@gmail.com> <9a8748490708301320o49d8e794vc5c37ffc938006f1@mail.gmail.com> <1188512393.6062.156.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1188512393.6062.156.camel@localhost>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday 31 August 2007 00:19:53 Joe Perches wrote:
> On Thu, 2007-08-30 at 22:20 +0200, Jesper Juhl wrote:
> > Ok, I must admit I didn't check with sparse since it seemed pointless
> > - we usually never cast void pointers to other pointer types,
> > specifically because the C language nicely guarantees that the right
> > thing will happen without the cast.  Sometimes we have to cast them to
> > integer types, su sure we need the cast there.   But what on earth
> > makes a "zd_addr_t *" so special that we have to explicitly cast a
> > "void *" to that type?
> 
> http://marc.info/?l=linux-netdev&m=117113743902549&w=1
> 

Thank you for that link Joe.

I'm not sure I agree with the __nocast, but I respect that this is 
the maintainers choice.

But, I still think the first chunk of the patch that removes the 
initial variable initialization makes sense. 
Initializing the variable to NULL is pointless since it'll never be
used before the kmalloc() call. So here's a revised patch that just
gets rid of that little detail.



No need to initialize to NULL when variable is never used before 
it's assigned the return value of a kmalloc() call.

Signed-off-by: Jesper Juhl <jesper.juhl-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---

diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index c39f198..30872fe 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -106,7 +106,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values, const zd_addr_t *addr
 {
 	int r;
 	int i;
-	zd_addr_t *a16 = (zd_addr_t *)NULL;
+	zd_addr_t *a16;
 	u16 *v16;
 	unsigned int count16;
 
