From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 11:10:06 +0100
Message-ID: <20091228101006.GA19984@elf.ucw.cz>
References: <20091227190802.GH11737@elf.ucw.cz>
 <20091228060759.GB13266@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atrey.karlin.mff.cuni.cz ([195.113.26.193]:56411 "EHLO
	atrey.karlin.mff.cuni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbZL1KKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 05:10:16 -0500
Content-Disposition: inline
In-Reply-To: <20091228060759.GB13266@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> >"I can't see" is not strong enough test, I'd say.
> >
> >For example, I can easily imagine something like pam falling back to
> >local authentication when network is unavailable. If you disable
> >network for su...
> >
> >It would be also extremely easy to DoS something like sendmail -- if
> >it forks into background and then serves other users' requests.
> 
> Pavel,
> 
> I spent some time this afternoon reflecting on the scenarios that you sketched
> above. This reflection resulted in three concrete responses:

There's more. You are introducing security holes. Don't.

>   1. Anyone depending on their network for authentication already has to deal
>      with availability faults. disablenetwork doesn't change anything
>      fundamental there.

Actually it does. Policy may well be "If the network works, noone can
log in locally, because administration is normally done over
network. If the network fails, larger set of people is allowed in,
because something clearly went wrong and we want anyone going around
to fix it."

>   2. Anyone able to use disablenetwork to block a privilege escalation via su
>      or to influence sendmail will be able to disrupt the privilege escalation
>      or mail transfer by manipulating the ancestors of su or sendmail in plenty
>      of other ways including, for example, via ptrace(), kill(), manipulation
>      of PATH, manipulation of X11 events and IPC, manipulation of TTYs, and so
>      on.

Please learn how setuid works. No, you can't ptrace su. Yes, su has to
deal with poisonous PATH. setuid programs are generally carefully
written to handle _known_ problems. You are adding disablenetwork that
they'll need to handle, and that's bad.

>   3. As I pointed out before, disablenetwork _is_ controlled by a build-time
>      configuration option, its use _is_ still subject to any existing MAC

CONFIG_ADD_SECURITY_HOLE is still bad idea.

You should either:

a) make disablenetwork reset to "enablenetwork" during setuid exec

or

b) disallow setuid execs for tasks that have network disabled.
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
