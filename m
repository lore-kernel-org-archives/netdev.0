From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 2/3] Security: Implement disablenetwork semantics. (v4)
Date: Mon, 11 Jan 2010 11:49:22 -0600
Message-ID: <20100111174922.GA17285@us.ibm.com>
References: <201001111007.EAG82373.VHFQSLFOFMOOJt@I-love.SAKURA.ne.jp>
 <20100111014530.GB4070@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
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
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw.cz>, Al Viro <viro@ZenIV.linux.org.uk>,
	K
To: Michael Stone <michael@laptop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:49260 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753037Ab0AKRtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 12:49:53 -0500
Content-Disposition: inline
In-Reply-To: <20100111014530.GB4070@heat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Michael Stone (michael@laptop.org):
> Tetsuo Handa wrote:
> 
> >Michael Stone wrote:
> >>Examples of software that I want to be able to gain privileges normally include:
> >>
> >>   rainbow, which requires privilege in order to add new accounts to the system
> >>   and in order to call setuid() but which does not require networking
> >>   privileges.
> >
> >If the system is not using local files (i.e. /etc/passwd and /etc/shadow),
> >the process who wants to add new accounts to the system might need network
> >access (e.g. to LDAP server), doesn't it?
> 
> General purpose account manipulation tools might need network access but
> rainbow handles all its account manipulations via state stored in
> /var/spool/rainbow/2. This state is made available to the rest of the system
> via libnss_rainbow.
> 
> Michael

Michael, I'm sorry, I should go back and search the thread for the
answer, but don't have time right now - do you really need
disablenetwork to be available to unprivileged users?  Or is it ok
to require CAP_SETPCAP (same thing required for dropping privs from
bounding set)?  Surely rainbow could be started either with that
capability, or even from a smaller, easier-to-audit wrapper that
has the capability, calls disablenetwork, then launches rainbow?

-serge
