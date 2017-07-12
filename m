From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: Lots of new warnings with gcc-7.1.1
Date: Tue, 11 Jul 2017 21:19:33 -0700
Message-ID: <20170711211933.388e2816@cakuba.netronome.com>
References: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tejun Heo <tj@kernel.org>, Jean Delvare <jdelvare@suse.com>,
        Guenter Roeck <linux@roeck-us.net>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Sathya Prakash <sathya.prakash@broadcom.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "the arch/x86 maintainers" <x86@kernel.org>,
        xen-devel <xen-devel@lists.xenproject.org>,
        linux-block <linux-block@vger.kernel.org>,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        IDE-ML <linux-ide@vger.kernel.org>,
        "linux-fbdev@vger.kernel.org" <linux-fbdev@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.9]:58071 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750988AbdGLETo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 00:19:44 -0400
In-Reply-To: <CA+55aFzXz-PxKSJP=hfHD+mfCX4M6+HMacWMkDz7KB8-3y55qw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Jul 2017 15:35:15 -0700, Linus Torvalds wrote:
> I do suspect I'll make "-Wformat-truncation" (as opposed to
> "-Wformat-overflow") be a "V=1" kind of warning.  But let's see how
> many of these we can fix, ok?

Somehow related - what's the stand on -Wimplicit-fallthrough?  I run
into the jump tables in jhash.h generating lots of warnings.  Is it OK
to do this?

--->8------

diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index 348c6f47e4cc..f6d6513a4c03 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -85,20 +85,19 @@ static inline u32 jhash(const void *key, u32 length, u32 initval)
 		k += 12;
 	}
 	/* Last block: affect all 32 bits of (c) */
-	/* All the case statements fall through */
 	switch (length) {
-	case 12: c += (u32)k[11]<<24;
-	case 11: c += (u32)k[10]<<16;
-	case 10: c += (u32)k[9]<<8;
-	case 9:  c += k[8];
-	case 8:  b += (u32)k[7]<<24;
-	case 7:  b += (u32)k[6]<<16;
-	case 6:  b += (u32)k[5]<<8;
-	case 5:  b += k[4];
-	case 4:  a += (u32)k[3]<<24;
-	case 3:  a += (u32)k[2]<<16;
-	case 2:  a += (u32)k[1]<<8;
-	case 1:  a += k[0];
+	case 12: c += (u32)k[11]<<24;	/* fall through */
+	case 11: c += (u32)k[10]<<16;	/* fall through */
+	case 10: c += (u32)k[9]<<8;	/* fall through */
+	case 9:  c += k[8];		/* fall through */
+	case 8:  b += (u32)k[7]<<24;	/* fall through */
+	case 7:  b += (u32)k[6]<<16;	/* fall through */
+	case 6:  b += (u32)k[5]<<8;	/* fall through */
+	case 5:  b += k[4];		/* fall through */
+	case 4:  a += (u32)k[3]<<24;	/* fall through */
+	case 3:  a += (u32)k[2]<<16;	/* fall through */
+	case 2:  a += (u32)k[1]<<8;	/* fall through */
+	case 1:  a += k[0];		/* fall through */
 		 __jhash_final(a, b, c);
 	case 0: /* Nothing left to add */
 		break;
@@ -131,11 +130,11 @@ static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
 		k += 3;
 	}
 
-	/* Handle the last 3 u32's: all the case statements fall through */
+	/* Handle the last 3 u32's */
 	switch (length) {
-	case 3: c += k[2];
-	case 2: b += k[1];
-	case 1: a += k[0];
+	case 3: c += k[2];	/* fall through */
+	case 2: b += k[1];	/* fall through */
+	case 1: a += k[0];	/* fall through */
 		__jhash_final(a, b, c);
 	case 0:	/* Nothing left to add */
 		break;
