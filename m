From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2] unix: properly account for FDs passed over unix sockets
Date: Tue, 2 Feb 2016 12:53:20 -0800
Message-ID: <CA+55aFykvz0vyWwxve-KHAcZe_hQuE5SDtazD=N_6gLpsU6LHw@mail.gmail.com>
References: <201601100657.u0A6vk1B025554@mail.home.local>
	<CANq1E4T0sqTTD4RsWXTUrFvsKvEsKsUiPbskWd=wAEVu83_Srg@mail.gmail.com>
	<56B0F574.5080105@stressinduktion.org>
	<CA+55aFw2AwsWbvwp6f8H+eExt_CMfh7VA3od6hto_M0hg9z3Tg@mail.gmail.com>
	<56B11278.8000805@stressinduktion.org>
	<CA+55aFz0CXGexEBmb8JU0+w7sFf3VfE3TpRzdj3aTiDxg2zDpg@mail.gmail.com>
	<20160202204955.GD25828@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Herrmann <dh.herrmann@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"???????? ??????????????????" <socketpair@gmail.com>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Simon McVittie <simon.mcvittie@collabora.co.uk>
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160202204955.GD25828@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 2, 2016 at 12:49 PM, Willy Tarreau <w@1wt.eu> wrote:
> On Tue, Feb 02, 2016 at 12:44:54PM -0800, Linus Torvalds wrote:
>>
>> Umm. I think the "struct cred" may change in between, can't it?
>
> You mean for example in case of setuid() or something like this ?

Yeah. I'd be worried about looking up the creds or user structure
later, and possibly getting a different one.

I'd much rather look it up at attach time, and just carry an extra
pointer around. That seems to be an inherently safer model where
there's no worry about "what happens if the user does X in the
meantime".

                  Linus
