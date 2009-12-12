From: Pavel Machek <pavel@ucw.cz>
Subject: s2disk encryption was Re: intermittent suspend
	problem	again
Date: Sat, 12 Dec 2009 20:27:12 +0100
Message-ID: <20091212192712.GB1308@ucw.cz>
References: <87fx93pwv2.fsf@tac.ki.iif.hu> <200912011328.15551.rjw@sisk.pl>
	<877ht68u4h.fsf@tac.ki.iif.hu> <200912012232.50951.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pm@lists.linux-foundation.org,
        Ferenc Wagner <wferi@niif.hu>,
        Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-pm-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <200912012232.50951.rjw@sisk.pl>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.linux-foundation.org>
List-Help: <mailto:linux-pm-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.linux-foundation.org?subject=subscribe>
Sender: linux-pm-bounces@lists.linux-foundation.org
Errors-To: linux-pm-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi!

> > >> On the other hand, I reverted 8fbd962e3, recompiled and replaced the
> > >> module, and got the freeze during hibernation.  And that was the bulk of
> > >> the changes since 2.6.31...  I'll revert the rest and test again, but
> > >> that seems purely cosmetic, so no high hopes.
> > >> 
> > >>> In addition to that, you can run multiple hibernation/resume cycles in
> > >>> a tight loop using the RTC wakealarm.
> > >> 
> > >> I'll do so, as soon as I find a way to automatically supply the dm-crypt
> > >> passphrase... or even better, learn to hibernate to ramdisk from the
> > >> initramfs. :)
> > >
> > > Well, you don't need to use swap encryption for _testing_. :-)
> > 
> > I use partition encryption, everything except for /boot is encrypted.
> 
> If /boot is big enough, you could use a swap file in /boot for the testing.
> 
> > Apropos: does s2disk perform encryption with a temporary key even if I
> > don't supply and RSA key, to protect mlocked application data from being
> > present in the swap after restore?
> 
> It can do that, but you need to provide a key during suspend and resume.
> 
> Otherwise it doesn't use a random key, because it would have to store it in
> the clear in the image header.

I believe it can use random key, stored in clear in image
header. Reason is... image header is easier to overwrite than removing
whole image.

That was original motivation for encryption... not having to overwrite
swap data with zeros.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
