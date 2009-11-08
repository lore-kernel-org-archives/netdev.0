From: Julia Lawall <julia@diku.dk>
Subject: Re: [PATCH v4 12/12] tree-wide: convert open calls
 to remove spaces to skip_spaces() lib function
Date: Sun, 8 Nov 2009 21:23:07 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911082103000.8143@ask.diku.dk>
References: <cover.1257602781.git.andre.goddard@gmail.com>
	<7d5883637aa976b54e944998f635d47a41618a75.1257602781.git.andre.goddard@gmail.com>
	<20091108184722.GA1647@mit.edu>
Reply-To: Linux filesystem caching discussion list <linux-cachefs@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pavel Roskin <proski@gnu.org>,
	Stefan Haberland <stefan.haberland@de.ibm.com>,
	Jan Kara <jack@suse.cz>, linux-cachefs@redhat.com,
	Mike Snitzer <snitzer@redhat.com>, Neil Brown <neilb@suse.de>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Jens Axboe <jens.axboe@oracle.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	"James E . J . Bottomley" <jejb@parisc-linux.org>,
	ibm-acpi-devel@lists.sourceforge.net, dm-devel@redhat.com,
	"H . Peter Anvin" <hpa@zytor.com>,
	Daire Byrne <Daire.Byrne@framestore.com>,
	Alasdair G Kergon <agk@redhat.com>, Greg Banks <gnb@melbourne.sgi.com>,
	Stefan Weinhuber <wein@de.ibm.com>,
	Eric Sandeen <sandeen@redhat.com>, Adam Belay <abelay@mit.edu>,
	Helge Deller <deller@gmx.de>, x86@kernel.org,
	James Morris <jmorris@namei.org>, Takashi Iwai <tiwai@suse.de>,
	=?iso-8859-1?Q?Andr=E9?= Goddard Rosa <andre.goddard@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.or
To: Theodore Tso <tytso@mit.edu>
Return-path: <linux-cachefs-bounces@redhat.com>
In-Reply-To: <20091108184722.GA1647@mit.edu>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cachefs>
List-Post: <mailto:linux-cachefs@redhat.com>
List-Help: <mailto:linux-cachefs-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cachefs>,
	<mailto:linux-cachefs-request@redhat.com?subject=subscribe>
Sender: linux-cachefs-bounces@redhat.com
Errors-To: linux-cachefs-bounces@redhat.com
List-Id: netdev.vger.kernel.org

> > Also, while at it, if we see (*str && isspace(*str)), we can be sure to
> > remove the first condition (*str) as the second one (isspace(*str)) also
> > evaluates to 0 whenever *str == 0, making it redundant. In other words,
> > "a char equals zero is never a space".

I tried the following semantic patch (http://coccinelle.lip6.fr), and got 
the results below.

@@
expression str;
@@

( // ignore skip_spaces cases
 while (*str &&  isspace(*str)) { \(str++;\|++str;\) }
|
- *str && 
  isspace(*str)
)

I haven't checked the results in any way, however.

julia

diff -u -p a/drivers/leds/led-class.c b/drivers/leds/led-class.c
--- a/drivers/leds/led-class.c
+++ b/drivers/leds/led-class.c
@@ -50,7 +50,7 @@ static ssize_t led_brightness_store(stru
 	unsigned long state = simple_strtoul(buf, &after, 10);
 	size_t count = after - buf;
 
-	if (*after && isspace(*after))
+	if (isspace(*after))
 		count++;
 
 	if (count == size) {
diff -u -p a/drivers/leds/ledtrig-timer.c b/drivers/leds/ledtrig-timer.c
--- a/drivers/leds/ledtrig-timer.c
+++ b/drivers/leds/ledtrig-timer.c
@@ -83,7 +83,7 @@ static ssize_t led_delay_on_store(struct
 	unsigned long state = simple_strtoul(buf, &after, 10);
 	size_t count = after - buf;
 
-	if (*after && isspace(*after))
+	if (isspace(*after))
 		count++;
 
 	if (count == size) {
@@ -127,7 +127,7 @@ static ssize_t led_delay_off_store(struc
 	unsigned long state = simple_strtoul(buf, &after, 10);
 	size_t count = after - buf;
 
-	if (*after && isspace(*after))
+	if (isspace(*after))
 		count++;
 
 	if (count == size) {
diff -u -p a/drivers/video/backlight/lcd.c b/drivers/video/backlight/lcd.c
--- a/drivers/video/backlight/lcd.c
+++ b/drivers/video/backlight/lcd.c
@@ -101,7 +101,7 @@ static ssize_t lcd_store_power(struct de
 	int power = simple_strtoul(buf, &endp, 0);
 	size_t size = endp - buf;
 
-	if (*endp && isspace(*endp))
+	if (isspace(*endp))
 		size++;
 	if (size != count)
 		return -EINVAL;
@@ -140,7 +140,7 @@ static ssize_t lcd_store_contrast(struct
 	int contrast = simple_strtoul(buf, &endp, 0);
 	size_t size = endp - buf;
 
-	if (*endp && isspace(*endp))
+	if (isspace(*endp))
 		size++;
 	if (size != count)
 		return -EINVAL;
diff -u -p a/drivers/video/display/display-sysfs.c b/drivers/video/display/display-sysfs.c
--- a/drivers/video/display/display-sysfs.c
+++ b/drivers/video/display/display-sysfs.c
@@ -67,7 +67,7 @@ static ssize_t display_store_contrast(st
 	contrast = simple_strtoul(buf, &endp, 0);
 	size = endp - buf;
 
-	if (*endp && isspace(*endp))
+	if (isspace(*endp))
 		size++;
 
 	if (size != count)
diff -u -p a/drivers/video/output.c b/drivers/video/output.c
--- a/drivers/video/output.c
+++ b/drivers/video/output.c
@@ -50,7 +50,7 @@ static ssize_t video_output_store_state(
 	int request_state = simple_strtoul(buf,&endp,0);
 	size_t size = endp - buf;
 
-	if (*endp && isspace(*endp))
+	if (isspace(*endp))
 		size++;
 	if (size != count)
 		return -EINVAL;
