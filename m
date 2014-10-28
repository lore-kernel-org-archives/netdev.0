From: Joe Perches <joe@perches.com>
Subject: [PATCH] carl9170: Convert byte_rev_table uses to bitrev8
Date: Tue, 28 Oct 2014 14:18:58 -0700
Message-ID: <1414531138.10912.12.camel@perches.com>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
	 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net>
	 <1414392371.8884.2.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, "Wang, Yalin"
	 <Yalin.Wang@sonymobile.com>, Russell King <linux@arm.linux.org.uk>,
	linux-mm@kvack.org, Will Deacon <Will.Deacon@arm.com>, Akinobu Mita
	 <akinobu.mita@gmail.com>, linux-arm-kernel@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>, LKML
	 <linux-kernel@vger.kernel.org>
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1414392371.8884.2.camel@perches.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Use the inline function instead of directly indexing the array.

This allows some architectures with hardware instructions
for bit reversals to eliminate the array.

Signed-off-by: Joe Perches <joe@perches.com>
---
On Sun, 2014-10-26 at 23:46 -0700, Joe Perches wrote:
> On Mon, 2014-10-27 at 14:37 +0800, Wang, Yalin wrote:
> > this change add CONFIG_HAVE_ARCH_BITREVERSE config option,
> > so that we can use arm/arm64 rbit instruction to do bitrev operation
> > by hardware.
[]
> > diff --git a/include/linux/bitrev.h b/include/linux/bitrev.h
> > index 7ffe03f..ef5b2bb 100644
> > --- a/include/linux/bitrev.h
> > +++ b/include/linux/bitrev.h
> > @@ -3,6 +3,14 @@
> >  
> >  #include <linux/types.h>
> >  
> > +#ifdef CONFIG_HAVE_ARCH_BITREVERSE
> > +#include <asm/bitrev.h>
> > +
> > +#define bitrev32 __arch_bitrev32
> > +#define bitrev16 __arch_bitrev16
> > +#define bitrev8 __arch_bitrev8
> > +
> > +#else
> >  extern u8 const byte_rev_table[256];

 drivers/net/wireless/ath/carl9170/phy.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/phy.c b/drivers/net/wireless/ath/carl9170/phy.c
index b80b213..dca6df1 100644
--- a/drivers/net/wireless/ath/carl9170/phy.c
+++ b/drivers/net/wireless/ath/carl9170/phy.c
@@ -994,7 +994,7 @@ static int carl9170_init_rf_bank4_pwr(struct ar9170 *ar, bool band5ghz,
 			refsel0 = 0;
 			refsel1 = 1;
 		}
-		chansel = byte_rev_table[chansel];
+		chansel = bitrev8(chansel);
 	} else {
 		if (freq == 2484) {
 			chansel = 10 + (freq - 2274) / 5;
@@ -1002,7 +1002,7 @@ static int carl9170_init_rf_bank4_pwr(struct ar9170 *ar, bool band5ghz,
 		} else
 			chansel = 16 + (freq - 2272) / 5;
 		chansel *= 4;
-		chansel = byte_rev_table[chansel];
+		chansel = bitrev8(chansel);
 	}
 
 	d1 =	chansel;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
