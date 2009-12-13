From: Michael Stone <michael@laptop.org>
Subject: setrlimit(RLIMIT_NETWORK) vs. prctl(???)
Date: Sun, 13 Dec 2009 00:09:00 -0500
Message-ID: <20091213050900.GC4369@heat>
References: <20091213034418.GA4416@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	=?iso-8859-1?Q?R=E9mi?= Denis-Courmont <rdenis@simphalempin.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Michael Stone <michael@laptop.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751154AbZLMFHL@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091213034418.GA4416@heat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

A colleague just asked me an excellent question about my approach which I'd
like to share with you. Paraphrasing, he wrote:

> rlimits seem very heavy for a simple inherited boolean flag. Also, creating
> a new one will require modifying a lot of delicate userland software.
> Wouldn't some new prctl() flags be a better choice?

Here's my response:

> You're absolutely right that choosing to expose this functionality as an
> rlimit (as opposed to as a new syscall or as a flag to an old syscall like
> prctl()) is a decision with complex consequences.
> 
> I picked rlimits for this patch (after trying the "new syscall" approach
> privately) because doing so provides exactly the interface, semantics, and
> userland integration that I want:
>
> interface: "unprivileged", "temporarily drop", "permanently drop", "get
> current state", "persist current state across exec()", and some room for
> future expansion of semantics by definining new state values between 0 and
> RLIMIT_INFINITY.
> 
> integration: lots of sandboxing code already contains logic to drop rlimits
> when starting up an isolated process. Furthermore, I think it would be really
> great to be able to limit networking from the shell via ulimit and on a
> per-user basis via /etc/security/limits.conf.
> 
> That being said, I'm not wedded to the decision. Could you give me some more
> specific examples of the kinds of changes in low-level userspace code that
> you're worried about?

Regards,

Michael
