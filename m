From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: disablenetwork (v5): Require CAP_SETPCAP to enable
Date: Mon, 18 Jan 2010 13:30:04 -0600
Message-ID: <20100118193004.GA17189@us.ibm.com>
References: <551280e51001161858q740bf246n2ed389920de689e7@mail.gmail.com>
 <20100117044825.GA2712@heat>
 <551280e51001162058n52ee94b7v5ccb10d80284bc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
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
	Pavel Machek <pavel@ucw.cz>, A
To: "Andrew G. Morgan" <morgan@kernel.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <551280e51001162058n52ee94b7v5ccb10d80284bc@mail.gmail.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Andrew G. Morgan (morgan@kernel.org):
> On Sat, Jan 16, 2010 at 8:48 PM, Michael Stone <michael@laptop.org> wrote:
> > Andrew Morgan wrote:
> >>
> >> Please use CAP_NET_ADMIN for this feature (and add the corresponding
> >> comment in include/linux/capabilities.h).
> >
> > Sure.
> > However, to make sure I understand the purpose of the adjustment, would you
> > mind saying a word or two about what considerations cause you to recommend
> > CAP_NET_ADMIN instead of (or in addition to?) CAP_SETPCAP?
> 
> If you take a look at the capabilities.h file, you'll see that each of
> the capabilities is preceded by an explanation of what privilege it
> enables.
> 
> CAP_SETPCAP refers to privileged manipulation of capabilities
> (permission to violate the normal capability rules) and nothing to do
> with the network.
> 
> You are adding something akin to a per-process tree firewall setting -
> deny/enable network access to this process.

I think I originally suggested CAP_SETPCAP - because it's not deny network
access to this process, but deny network access to all child processes as
well, even if they are more privileged (through setuid-root or file caps).

CAP_NET_ADMIN is probably more straightforward, though.  Who's going to
think to add CAP_SETPCAP to a binary that is intended to drop network
perms, realistically...

> I think you'll agree that
> the CAP_NET_ADMIN description is a much better match for this.

I think it'll be more intuitive to most people so I agree.

-serge
