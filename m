From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 22:08:01 +0100
Message-ID: <20091228210801.GA1945@ucw.cz>
References: <20091228101006.GA19984@elf.ucw.cz> <20091228163108.GC13266@heat>
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
	Am?rico Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091228163108.GC13266@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>>   1. Anyone depending on their network for authentication already has to deal
>>      with availability faults. disablenetwork doesn't change anything
>>      fundamental there.
>
>> Actually it does. Policy may well be "If the network works, noone can
>> log in locally, because administration is normally done over
>> network. If the network fails, larger set of people is allowed in,
>> because something clearly went wrong and we want anyone going around
>> to fix it."
>
> Have you actually seen this security policy in real life? I ask because it
> seems quite far-fetched to me. Networks are just too easy to attack. Seems to
> me, from this casual description, that you're just asking to be ARP- or
> DNS-poisoned and rooted with this one.

It is little far-fetched; but it would make sense on 'secure' network,
where you can't do arp attacks. You can bet that someone out there
does it.

>> Please learn how setuid works. 
>
> I am quite familiar with how setuid works. I was suggesting a number of ways to
> modify the behavior of su's *ancestors*; not su. (I apoligize that my writing
> was not more clear on this point.) 
>
> In retrospect, substituting "abort()" for "disablenetwork()" better explains my
> point. Who can call disablenetwork() to cause a problem who can't just as well
> have called abort() or kill(0, SIGSTOP) at the same time?

You can't sigstop sendmail, right?

> Still, I take your point that there may be people out there who have written
> configurations for setuid executables under the belief that their networks are
> reliable and available in the presence of attackers.

Good.

>> You should either:
>
>> a) make disablenetwork reset to "enablenetwork" during setuid exec
>> b) disallow setuid execs for tasks that have network disabled.
>
> Neither of these work. The first is incorrect because a disablenetwork'ed
> process could transmit anything it wants through ping. The second is one that I
> feel is unsafe because I don't feel that I can predict its
>consequences.

Ok, you could just remove ping from your systems, but I see, b) is
better solution. 

Why do you think it is unsafe? Its clearly secure, at least from 'user
can't attack other users on shared machine'...

It may cause some failures, but given how rare setuid stuff is these
days, I doubt it.

> However, there's a third option that I think might work. What do you think of
> treating being network-disabled the same way we treat RLIMIT_NOFILE? That is,
> what about:
>
> c) permit capable processes (such as euid 0) to remove networking restrictions
>    by further calls to prctl(PR_SET_NETWORK)?

I'm afraid that does not help... you'd have to audit/modify existing
setuid programs to keep system secure. No-no.
								Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
