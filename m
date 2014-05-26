From: Willy Tarreau <w@1wt.eu>
Subject: Re: [RFC][PATCH] netlink: Only check file credentials for implicit destinations
Date: Mon, 26 May 2014 15:39:07 +0200
Message-ID: <20140526133907.GD13929@1wt.eu>
References: <CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com> <CA+55aFzZg3LfpPpx3+83sB0npd9863NTMqvsCArMDjg-9J151A@mail.gmail.com> <CALCETrVWkW16Y7hOq-mA1auJjRXmwiAUfAGurK0-2bOdbZu_dA@mail.gmail.com> <20140522170505.64ef87a2@griffin> <87ioow6pt6.fsf@x220.int.ebiederm.org> <CA+55aFxybf=ya2RE5nzf10Km+JZ3=HqXGVCHYcteW2EVAUww+g@mail.gmail.com> <87zji6v2mk.fsf_-_@x220.int.ebiederm.org> <CALCETrVezgCY61wSO_5kTJz-tX5HdYwbEPpS-HAy8bg7KEqibA@mail.gmail.com> <874n0ds9sk.fsf@x220.int.ebiederm.org> <CA+55aFwsomt04G8MTJBU2YEn4XLuRw14C4yU1b2sWDmk5HWrcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Andy Lutomirski <luto@amacapital.net>,
	"Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Michael Kerrisk-manpages <mtk.manpages@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:35981 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122AbaEZNks (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 May 2014 09:40:48 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFwsomt04G8MTJBU2YEn4XLuRw14C4yU1b2sWDmk5HWrcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 25, 2014 at 05:32:55PM -0700, Linus Torvalds wrote:
> On Sun, May 25, 2014 at 4:44 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
> >
> > But I agree that since connect on sockets is really the equivalent of
> > open on files, and unprivileged users can change where a socket is
> > connected to, using a struct cred captured at connect() time is better
> > than the struct cred captured at socket() time.
> 
> Ack. Conceptually, "connect/listen" really ends up being the
> equivalent to pathname lookup, not so much "socket()", which just
> mostly creates the placeholder for future work.
> 
> That would also be very much consistent with making "sendto" look at
> current creds rather than cached creds (but only _if_ it has an
> address, of course - using "sendto(... , NULL, 0)" should _not_
> somehow be different from "send()"). So I think that from a
> sensibility and "please explain the semantics to me" standpoint, that
> would be sane semantics.

I like this! And it's very much consistent with sendto() being used
as an alternative to connect() with TCP Fastopen.

Willy
