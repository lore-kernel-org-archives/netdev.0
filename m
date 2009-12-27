From: "Serge E. Hallyn" <serge@hallyn.com>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Sun, 27 Dec 2009 10:12:03 -0600
Message-ID: <20091227161203.GA20031@hallyn.com>
References: <20091227150300.GB19414@hallyn.com> <20091227154747.GA12645@heat>
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
	Pavel Machek <pavel@ucw.cz>
To: Michael Stone <michael@laptop.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091227154747.GA12645@heat>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Michael Stone (michael@laptop.org):
> Serge Hallyn writes:
>
>> Michael Stone, without looking back over the patches, do you also
>> restrict opening netlink sockets?  
>
> The current version of the patch restricts netlink sockets which were not bound
> to an address before calling disablenetwork(). It does so primarily on the
> grounds of "fail safe", due to the following sorts of discussions and
> observations:
>
>   http://kerneltrap.org/mailarchive/linux-kernel/2007/12/7/493793/thread
>   http://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2006-5461
>   http://marc.info/?l=linux-kernel&m=125448727130301&w=2
>
> I would be willing to entertain an argument that some kind of exemption for
> AF_NETLINK ought to be introduced but I'd need to hear some more details before
> I could implement it and before I could satisfy myself that the result was
> sound.
>
>> Should we worry about preventing an error message from being sent to the
>> audit daemon?
>
> I've considered the matter and I don't see much to worry about at this 
> time. 

I don't either, because I don't know of userspace programs other than
/bin/login (and I'm guessing at that) using netlink to send audit messages,
but I could be wrong, and there could be "important software" out there
that does so.

> The first reason why I'm not too worried is that anyone in a position to use
> disablenetwork for nefarious purposes is also probably able to use ptrace(),
> kill(), and/or LD_PRELOAD to similar ends.

How do you mean?  I thought that disabling network was a completely
unprivileged operation?  And subsequently executing a setuid-root
application won't reset the flag.

> The second reason why I'm not too worried is that I believe it to be
> straightforward to use the pre-existing MAC frameworks to prevent individually
> important processes from dropping networking privileges.
>
> Do you have a specific concern in mind not addressed by either of these
> observations?

Near as I can tell the worst one could do would be to prevent remote
admins from getting useful audit messages, which could give you unlimited
time to keep re-trying the server, on your quest to a brute-force attack
of some sort, i.e. restarting the server with random passwords, and now
no audit msg about the wrong password gets generated, so you're free to
exhaust the space of valid passwords.

Not saying I'm all that worried about it - just something that came to
mind.

-serge
