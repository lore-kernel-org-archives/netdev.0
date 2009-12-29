From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: RFC: disablenetwork facility. (v4)
Date: Tue, 29 Dec 2009 21:35:19 +0000
Message-ID: <20091229213519.09644bf9@lxorguk.ukuu.org.uk>
References: <20091229050114.GC14362@heat>
	<m1y6km11lj.fsf@fess.ebiederm.org>
	<20091229151146.GA32153@us.ibm.com>
	<3e8340490912290805s103fb789y13acea4a84669b20@mail.gmail.com>
	<m3oclhzgm4.fsf@ursa.amorsen.dk>
	<m17hs5y0mg.fsf@fess.ebiederm.org>
	<20091229211139.0732a0c1@lxorguk.ukuu.org.uk>
	<3e8340490912291314m5e1b72e6s6e394d0a8cf95d00@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Benny Amorsen <benny+usenet@amorsen.dk>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Michael Stone <michael@laptop.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?UTF-8?B?QW3DqXJpY28=?= Wang <xiyou.wangcong@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Samir Bellabes <sam@synack.fr>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Pavel Machek <pavel@ucw
To: Bryan Donlan <bdonlan@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752865AbZL2Vdw@vger.kernel.org>
In-Reply-To: <3e8340490912291314m5e1b72e6s6e394d0a8cf95d00@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The security hole is that secrets in a setuid application with
> other-exec but no other-read permission can be read when the
> filesystem is mounted nosuid.

Erm no

We enforce the following anyway to prevent execution being permitted to
make file copies. Most Unixen do although its historical value is
primarily to prevent people "stealing valuable proprietary intellectual
software assets".


      } else if (file_permission(bprm->file, MAY_READ) ||
                    bprm->interp_flags & BINPRM_FLAGS_ENFORCE_NONDUMP)
      { 
             set_dumpable(current->mm, suid_dumpable);
      }

There does appear to be a small race in modern versions of that code
which wants swatting.
