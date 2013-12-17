From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Tue, 17 Dec 2013 22:49:14 +0100
Message-ID: <1254825772.20131217224914@eikelenboom.it>
References: <1342235583.20131211182804@eikelenboom.it> <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com> <871324710.20131211191104@eikelenboom.it> <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com> <1937118387.20131216122200@eikelenboom.it> <52AEE60B.6030509@broadcom.com> <19210260274.20131216135644@eikelenboom.it> <CAGRGNgXHemM2FfnXgW5RbzhFT+9SfUfVkjdysK3+=_u3hWSacw@mail.gmail.com> <1534126119.20131217104548@eikelenboom.it> <387552477.20131217213319@eikelenboom.it> <20131217212709.GB5624@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Julian Calaby <julian.calaby@gmail.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131217212709.GB5624@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Tuesday, December 17, 2013, 10:27:09 PM, you wrote:

> On Tue, Dec 17, 2013 at 09:33:19PM +0100, Sander Eikelenboom wrote:
> [...]
>> > It's the official Debian package.
> [...]
>> > I will report back when i have tested converting the wireless stuff to loadable modules / seeing if i can put the CRDA stuff in initrd.
>> 
>> With all the wireless stuff switched to loadable modules it *does* work.
>> 
>> So the problem is that:
>> The current code blocks all future regulatory domain setting attempts forever (till the next reboot)
>> when it can't find the CRDA. This can and does happen when the modules are compiled in and the CRDA is not in initrd.
>> 
>> So from the question department:
>> 
>> A) Why doesn't the code timeout the processing of a regulatory domain hint and remove the pending request when it aborts ?
>> B) Why isn't the CRDA treated as firmware and placed in /lib/firmware, which has a much greater chance of automagically appearing in initrd ?
> [...]

> It doesn't make any logical sense to put a userland program in
> /lib/firmware, and it wouldn't have any effect on the initramfs
> builders I'm familiar with (which look at module metadata to work
> out which files to include from /lib/firmware).

Ah yes of course stupid, it's not just a blob of the regdb but
a userland program.

> Debian official kernels use modular drivers, and neither
> initramfs-tools nor dracut includes wireless drivers in the initramfs.
> If you build a custom kernel with built-in drivers then you most
> likely don't need an initramfs at all.

> As maintainer of crda in Debian, I could add an initramfs hook that
> would include it in an initramfs.  But I don't understand why it would
> be worth doing so.  Why is it so useful to have wireless drivers
> built-in *and* an initramfs?  If you think I should do this then open
> a bug (reportbug crda).

Indeed, I looked for a crda hook for initramfs-tools but didn't find it, so skipped that idea
for the moment.

So if i combine the two .. it's essentially just a very bad idea to compile the wireless stuff in.
It needs a access to a userland program at module load time, or it will block forever.

> Ben.
