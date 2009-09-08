From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Stop using tasklets for bottom halves
Date: Tue, 8 Sep 2009 07:08:58 +0200
Message-ID: <200909080708.59702.mb@bu3sch.de>
References: <43e72e890909071558s637b45c7i10807587dc40e8c4@mail.gmail.com> <1252376254.21261.2052.camel@gandalf.stny.rr.com> <200909080650.43181.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Matt Smith <Matt.Smith@atheros.com>,
	Kevin Hayes <kevin@atheros.com>,
	Bob Copeland <me@bobcopeland.com>, Jouni Malinen <j@w1.fi>,
	Ivan Seskar <Seskar@winlab.rutgers.edu>, ic.felix@gmail.com
To: rostedt@goodmis.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753500AbZIHFJS@vger.kernel.org>
In-Reply-To: <200909080650.43181.mb@bu3sch.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 08 September 2009 06:50:41 Michael Buesch wrote:
> On Tuesday 08 September 2009 04:17:34 Steven Rostedt wrote:
> > > Process context is too slow.
> > 
> > Well, I'm hoping to prove the opposite. I'm working on some stuff that I
> > plan to present at Linux Plumbers. I've been too distracted by other
> > things, but hopefully I'll have some good numbers to present by then.
> 
> I recently converted the b43 driver to threaded interrupt handlers and
> a workqueue based TX mechanism. (My motivation was porting b43 to the SDIO bus that
> needs to sleep, so requires process context).
> 
> There are two things that I noticed. When looking at the "idle" percentage in "top"
> it regressed quite a bit when using threaded IRQ handlers. It shows about 8% less
> idle. This is with threaded IRQs patched in, but without WQ TX mechanism. Applying
> the WQ TX mechanism does not show any noticeable effect in "top".
> 
> I'm not quite sure where the 8% slowdown on threaded IRQ handlers come from. I'm not
> really certain that it's _really_ a regression and not just a statistics accounting quirk.
> Why does threaded IRQs slow down stuff and threaded TX does not at all? That does not
> make sense at all to me.
> 
> I think there's no real reason for process context being slow in general. It's just that
> we have additional context switches. But these are fast on Linux.
> 

Ok, I just did another test. I used a workqueue instead of the standard kernel threaded
IRQ infrastructure. Now the slowdown is only about 4% in "top". Maybe that shows room
for improvement in the threaded IRQ implementation...

B43 does call mac80211's "irqsafe" TX-status and RX functions. They schedule
additional tasklets. That is not required, however. Maybe I should remove that stuff and
retry my tests. That should also improve stuff a bit.

And yes, I notice that "top" is actually crap for testing performance issues. :)

-- 
Greetings, Michael.
