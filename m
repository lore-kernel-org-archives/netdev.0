From: Michael Stone <michael@laptop.org>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 11:31:09 -0500
Message-ID: <20091228163108.GC13266@heat>
References: <20091228101006.GA19984@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
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
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Michael Stone <michael@lapt
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091228101006.GA19984@elf.ucw.cz>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Pavel,
> 
> I spent some time this afternoon reflecting on the scenarios that you sketched
> above. This reflection resulted in three concrete responses:

> There's more. You are introducing security holes. Don't.

My users care about things like stopping compromised processes from leaking
their documents or sending spam; they do not use the network in the ways you
seem to be concerned about.

>   1. Anyone depending on their network for authentication already has to deal
>      with availability faults. disablenetwork doesn't change anything
>      fundamental there.

> Actually it does. Policy may well be "If the network works, noone can
> log in locally, because administration is normally done over
> network. If the network fails, larger set of people is allowed in,
> because something clearly went wrong and we want anyone going around
> to fix it."

Have you actually seen this security policy in real life? I ask because it
seems quite far-fetched to me. Networks are just too easy to attack. Seems to
me, from this casual description, that you're just asking to be ARP- or
DNS-poisoned and rooted with this one.

>   2. Anyone able to use disablenetwork to block a privilege escalation via su
>      or to influence sendmail will be able to disrupt the privilege escalation
>      or mail transfer by manipulating the ancestors of su or sendmail in plenty
>      of other ways including, for example, via ptrace(), kill(), manipulation
>      of PATH, manipulation of X11 events and IPC, manipulation of TTYs, and so
>      on.

> Please learn how setuid works. 

I am quite familiar with how setuid works. I was suggesting a number of ways to
modify the behavior of su's *ancestors*; not su. (I apoligize that my writing
was not more clear on this point.) 

In retrospect, substituting "abort()" for "disablenetwork()" better explains my
point. Who can call disablenetwork() to cause a problem who can't just as well
have called abort() or kill(0, SIGSTOP) at the same time?

Still, I take your point that there may be people out there who have written
configurations for setuid executables under the belief that their networks are
reliable and available in the presence of attackers.

>>   3. As I pointed out before, disablenetwork _is_ controlled by a build-time
>>      configuration option, its use _is_ still subject to any existing MAC
> 
> CONFIG_ADD_SECURITY_HOLE is still bad idea.

Perhaps for your users. For me and for the users of my software, having
CONFIGURE_SECURITY_DISABLENETWORK is far better than not having it because it
permits us to close many other far more significant holes.

> You should either:

> a) make disablenetwork reset to "enablenetwork" during setuid exec
> b) disallow setuid execs for tasks that have network disabled.

Neither of these work. The first is incorrect because a disablenetwork'ed
process could transmit anything it wants through ping. The second is one that I
feel is unsafe because I don't feel that I can predict its consequences.

However, there's a third option that I think might work. What do you think of
treating being network-disabled the same way we treat RLIMIT_NOFILE? That is,
what about:

c) permit capable processes (such as euid 0) to remove networking restrictions
    by further calls to prctl(PR_SET_NETWORK)?

Regards,

Michael
