From: Michael Stone <michael@laptop.org>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Mon, 28 Dec 2009 01:07:59 -0500
Message-ID: <20091228060759.GB13266@heat>
References: <20091227190802.GH11737@elf.ucw.cz>
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
In-Reply-To: <20091227190802.GH11737@elf.ucw.cz>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:
> "I can't see" is not strong enough test, I'd say.
> 
> For example, I can easily imagine something like pam falling back to
> local authentication when network is unavailable. If you disable
> network for su...
> 
> It would be also extremely easy to DoS something like sendmail -- if
> it forks into background and then serves other users' requests.

Pavel,

I spent some time this afternoon reflecting on the scenarios that you sketched
above. This reflection resulted in three concrete responses:

   1. Anyone depending on their network for authentication already has to deal
      with availability faults. disablenetwork doesn't change anything
      fundamental there.

   2. Anyone able to use disablenetwork to block a privilege escalation via su
      or to influence sendmail will be able to disrupt the privilege escalation
      or mail transfer by manipulating the ancestors of su or sendmail in plenty
      of other ways including, for example, via ptrace(), kill(), manipulation
      of PATH, manipulation of X11 events and IPC, manipulation of TTYs, and so
      on. 

   3. As I pointed out before, disablenetwork _is_ controlled by a build-time
      configuration option, its use _is_ still subject to any existing MAC
      policy, and it _is_ easy to control for simply by talking to a
      known-unrestricted process over an unrestricted IPC channel like a Unix
      socket.

and a short meta-response:

   As I see it, the whole point of isolation facilities like disablenetwork is
   to convert _nasty_ faults like secrecy and integrity faults into _local_
   availability faults. Consequently, it is completely unsurprising that we
   can't meet stringent availability goals via isolation without either relaxing
   our other security goals or falling back to strong assumptions about the
   state of our initial environment.

   However, we should not therefore ignore the bottom line which is that
   the additional isolation enabled by disablenetwork represents an excellent
   security risk/reward tradeoff for many people and should be made more widely
   available to these people on these grounds.

Regards,

Michael

P.S. - Thanks again for your assistance in thinking through these scenarios and
in refining the security case for the disablenetwork feature.
