From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix sockets
Date: Tue, 2 Feb 2016 12:44:54 -0800
Message-ID: <CA+55aFz0CXGexEBmb8JU0+w7sFf3VfE3TpRzdj3aTiDxg2zDpg@mail.gmail.com>
References: <201601100657.u0A6vk1B025554@mail.home.local>
	<CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
	<56B0F574.5080105@stressinduktion.org>
	<CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com>
	<56B11278.8000805@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Herrmann <dh.herrmann@gmail.com>, Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	=?UTF-8?B?0JzQsNGA0Log0JrQvtGA0LXQvdCx0LXRgNCz?=
	<socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B11278.8000805@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 2, 2016 at 12:32 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>
> Unfortunately we never transfer a scm_cookie via the skbs but merely use it
> to initialize unix_skb_parms structure in skb->cb and destroy it afterwards.

Ok, I obviously didn't check very closely.

> But "struct pid *" in unix_skb_parms should be enough to get us to
> corresponding "struct cred *" so we can decrement the correct counter during
> skb destruction.

Umm. I think the "struct cred" may change in between, can't it?

So I don't think you can later look up the cred based on the pid.

Could we add the cred pointer (or just the user pointer) to the unix_skb_parms?

Or maybe just add it to the "struct scm_fp_list"?

               Linus
