From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] tcp: Replace infinite loop on recvmsg bug with proper
 crashusers
Date: Wed, 7 Nov 2012 12:15:41 -0500
Message-ID: <20121107171541.GA24482@redhat.com>
References: <1352247335-10396-1-git-send-email-jwerner@chromium.org>
 <20121107013907.GA31185@redhat.com>
 <CAODwPW-636Sn3B4CYajvrgccXxresZwPLg2UFz6xDDk9-FfTYQ@mail.gmail.com>
 <20121107155434.GA17677@redhat.com>
 <1352305752.3140.4449.camel@edumazet-glaptop>
 <20121107164358.GA20495@redhat.com>
 <1352307902.3140.4588.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julius Werner <jwerner@chromium.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Eric Dumazet <edumazet@chromium.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1352307902.3140.4588.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2012 at 09:05:02AM -0800, Eric Dumazet wrote:
 > On Wed, 2012-11-07 at 11:43 -0500, Dave Jones wrote:
 > 
 > > dude, look at the bug reports I just pointed you at.
 > > People _are_ aware there are bugs there.
 > > 
 > If I remember well, I helped to fix some of them.

indeed, and I commend you for it. I want to help you fix more ;)

 > >  > I understand a distro maintainer has its own choices, but for upstream
 > >  > kernel we want to have early reports.
 > > 
 > > I'm running out of ways to word this, but I'll try again.
 > > You won't get those early reports if you turn this into a BUG().
 > > 
 > >  > This bug is fatal and a security issue. BUG() is appropriate.
 > > 
 > > turning a bug into a remote DoS is also a security issue.
 > 
 > Apparently in some cases we can loop and fill the syslog, or
 > else Julius wouldnt have sent a patch.
 > 
 > So the proper fix is to emit this message only once, and to find
 > a way to alert the user security is compromised.
 > 
 > So if BUG() isnt good, just use WARN_ON_ONCE()
 > 
 > I feel that WARN_ON_ONCE() wont be clear enough to the user, especially
 > if we recover from this by closing the tcp session, exactly as if we
 > received a proper FIN.

Judging by the mangled traces we've seen, further reports after the initial
one aren't too useful anyway.  Automated detectors like abrt should be
able to pick up these traces from the logs on the next reboot.
(Which would probably be better than it trying to file them immediately over
 the network when the tcp layer is so confused)

sidenote: If the integrity of the tcp layer is in question, maybe some kind of
localised version of BUG() that just shuts down that subsystem might
be something worth persueing.

 > Really if you object a BUG() here, I cant understand you didnt shout to
 > other BUG() uses in the kernel.

When I see them, I call them. But I am just one person, and usage of that
macro is like a disease.

	Dave
