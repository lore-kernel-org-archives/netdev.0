From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix sockets
Date: Tue, 2 Feb 2016 21:39:29 +0100
Message-ID: <20160202203929.GC25828@1wt.eu>
References: <201601100657.u0A6vk1B025554@mail.home.local> <CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com> <56B0F574.5080105@stressinduktion.org> <CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com> <56B11278.8000805@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	???????? ?????????????????? <socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56B11278.8000805@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 02, 2016 at 09:32:56PM +0100, Hannes Frederic Sowa wrote:
> But "struct pid *" in unix_skb_parms should be enough to get us to 
> corresponding "struct cred *" so we can decrement the correct counter 
> during skb destruction.
> 
> So:
> 
> We increment current task's unix_inflight and also check the current 
> task's limit during attaching fds to skbs and decrement the inflight 
> counter via "struct pid *". This looks like it should work.

I like it as well, the principle sounds sane.

> >That way it's always the person who actually does the send (rather
> >than the opener of the socket _or_ the opener of the file that gets
> >passed around) that gets credited, and thanks to the cred pointer we
> >can then de-credit them properly.
> 
> Exactly, I try to implement that. Thanks a lot!

Thanks to you Hannes, I appreciate that you work on it, it would take
much more time to me to dig into this.

Willy
