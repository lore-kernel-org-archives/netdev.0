From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Fri, 15 Feb 2013 08:55:39 +0100
Message-ID: <20130215075539.GB7535@1wt.eu>
References: <20130207175240.GA12520@www.outflux.net> <20130207103950.662698ea@nehalam.linuxnetplumber.net> <CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com> <87y5eq87pa.fsf@xmission.com> <CAGXu5jJKQSDo61TD0Jgn9Gq8TL2rCUVbA=Kq4AvfeFUb2FdJMw@mail.gmail.com> <87r4ki6oi1.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Yuchung Cheng <ycheng@google.com>,
	Shan Wei <davidshan@tencent.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87r4ki6oi1.fsf@xmission.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric,

On Thu, Feb 14, 2013 at 11:10:46PM -0800, Eric W. Biederman wrote:
> Kees Cook <keescook@chromium.org> writes:
> 
> > On Thu, Feb 14, 2013 at 9:30 PM, Eric W. Biederman
> > <ebiederm@xmission.com> wrote:
> >> Kees Cook <keescook@chromium.org> writes:
> >>
> >>> The patch would not break it -- it defaults the sysctl to staying enabled.
> >>>
> >>> If you mean the documentation should be updated, sure, that's easy to do.
> >>>
> >>> David: I know you aren't a fan of this patch, but I'd like to try to
> >>> convince you. :) This leaves the feature enabled and add a toggle for
> >>> systems (like Chrome OS) that don't want to risk this DoS at all.
> >>> There are so very many other toggle, I don't see why this one would be
> >>> a problem to add.
> >>
> >> Chrome OS has no plans to implement webrtc?  Last I had read that
> >> support had been added to the release versions of Chrome, and was in the
> >> development builds of firefox.  I really don't belive that there are
> >> many systems that don't intend to run a web browser.
> >
> > I haven't looked at the internals of webrtc. Are you implying some
> > feature in it relies on the TCP simultaneous connect?
> 
> I am saying that yes.
> 
> webrtc is built on ICE (interactivity connectivity establishment).  ICE
> support for TCP (RFC6544) uses TCP simultaneous connect.  webrtc
> supports tcp connections.

Then I suspect that a large number of firewalls will need updates after
significant rework for this proposal to succeed. I'm not saying this will
not eventually happen, but there are significant risks associated with
this feature.  Netfilter had this in the window tracking patches around
2002-2003 and this had to be reverted because a client was able to establish
complete connections by sending SYN-SYN/ACK-ACK itself. Other products will
fall through these cracks.

And last but not least, it's the only behaviour in TCP which allows a
random attacker to prevent a connection from establishing by guessing
only a 16-bit port, regardless of any sequence number. Considering how
we've been bothered by people who considered that our sequence numbers
were not random enough, I already expect that the absolute lack of need
of a sequence number will bring new funny articles.

Back then, I did a PoC which permanently prevented an anti-virus proxy
from establishing any connection to its update server, and it did not
require a lot of traffic obviously. People running such proxies probably
don't need webrtc with its assorted lot of issues.

I'm not advocating for pushing the patch, I understand it's not desired.
I just want to ensure that people understand what simultaneous connect
means in terms of DoS for a feature which is rarely used and rarely
technically possible at all.

Regards,
Willy

