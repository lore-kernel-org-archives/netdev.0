From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [0/5] bcma/brcmsmac suspend/resume cleanups and fixes
Date: Sat, 14 Jan 2012 11:15:27 -0800
Message-ID: <CA+55aFxTkKwTy8mq9vRzHLNE7W8SYd5kbg2Ofr8LiG0DznLy6A@mail.gmail.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com> <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <4F101047.4090902@broadcom.com> <CA+55aFxtaw+FF8wRf9td1rU0A_vhM8XwgSznzE-ph_4j=t5gWg@mail.gmail.com>
 <20120114122222.GA21233@nautica>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Arend van Spriel <arend@broadcom.com>,
	=?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Alwin Beukers <alwin@broadcom.com>,
	Roland Vossen <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: Dominique Martinet <asmadeus@codewreck.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43421 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755057Ab2ANTPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jan 2012 14:15:51 -0500
Received: by werb13 with SMTP id b13so1154845wer.19
        for <netdev@vger.kernel.org>; Sat, 14 Jan 2012 11:15:50 -0800 (PST)
In-Reply-To: <20120114122222.GA21233@nautica>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 14, 2012 at 4:22 AM, Dominique Martinet
<asmadeus@codewreck.org> wrote:
>
> Sorry to hijack this thread, but I had the exact same problem Arend has
> and disabling MCE fixed it.. Since it froze only after resume and it
> didn't send anything to netconsole at this moment I've had this for some
> time without any good debug info, so first is a thank you!
>
> I'd like to try if the fix in current -git works, could you remind me
> the exact tree name you call this?


  git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux

is the main tree. The old "linux-2.6" name is just a symlink alias to it.

The commit that should fix MCE is just a oneliner: commit a3301b751b19
("x86/mce: Fix CPU hotplug and suspend regression related to MCE").

> I'm familiar with linux-2.6.git, wireless-testing.git, and
> linux-next.git, but it's not resolved in linux-next.git not
> linux-2.6.git's HEAD at the very least.

If it's not resolved in linux-2.6, then you have a different problem.

Or, possibly, the mirroring hadn't quite happened yet when you fetched
it - so it's worth double-checking that you have that commit
a3301b751b19 in your tree. But kernel.org git mirroring has been
pretty fast now that it uses gitorious.

> By the way, resume/suspend works with your patches over linux-next.git
> with a bcm4313 on a eeepc1215b!

Good. So they probably didn't break anything. It's always hard to tell
with drivers: even if it's an "obvious fix", the old code may have
worked for random reasons, and fixing it then breaks.

But I do think the patches should be pretty safe. The PCI layer
generally does all the PCI-level suspend/resumes correctly, and
drivers that try to do it are more likely to mess it up than not (that
didn't use to be true long ago, which is why many drivers still do it
- legacy baggage).

                           Linus
