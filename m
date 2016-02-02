From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix sockets
Date: Tue, 2 Feb 2016 21:58:02 +0100
Message-ID: <20160202205802.GE25828@1wt.eu>
References: <201601100657.u0A6vk1B025554@mail.home.local> <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com> <56B0F574.5080105@stressinduktion.org> <CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com> <56B11278.8000805@stressinduktion.org> <CA+55aFz0CXGexEBmb8JU0+w7sFf3VfE3TpRzdj3aTiDxg2zDpg@mail.gmail.com> <20160202204955.GD25828@1wt.eu> <CA+55aFykvz0vyWwxve-KHAcZe_hQuE5SDtazD=N_6gLpsU6LHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	???????? ?????????????????? <socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFykvz0vyWwxve-KHAcZe_hQuE5SDtazD=N_6gLpsU6LHw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 02, 2016 at 12:53:20PM -0800, Linus Torvalds wrote:
> On Tue, Feb 2, 2016 at 12:49 PM, Willy Tarreau <w@1wt.eu> wrote:
> > On Tue, Feb 02, 2016 at 12:44:54PM -0800, Linus Torvalds wrote:
> >>
> >> Umm. I think the "struct cred" may change in between, can't it?
> >
> > You mean for example in case of setuid() or something like this ?
> 
> Yeah. I'd be worried about looking up the creds or user structure
> later, and possibly getting a different one.
> 
> I'd much rather look it up at attach time, and just carry an extra
> pointer around. That seems to be an inherently safer model where
> there's no worry about "what happens if the user does X in the
> meantime".

Normally we can only change from root to non-root, and we don't apply
the limits to root, so if we have the ability to only store one bit
indicating "not tracked" or to simply nullify one pointer to avoid
counting in flight FDs for root, we don't take the risk to recredit
them to the target user after a change.

I just don't know if we can do that though :-/

Willy
