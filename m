From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 10 Mar 2011 16:29:30 -0800
Message-ID: <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
References: <20110310.153444.115930379.davem@davemloft.net>
 <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com> <20110310.155556.48513201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110310.155556.48513201.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2011 at 3:55 PM, David Miller <davem@davemloft.net> wro=
te:
> I should have put:
>
> =A0 =A0 =A0 =A0Merge to get commit 8909c9ad8ff03611c9c96c9a92656213e4=
bb495b
> =A0 =A0 =A0 =A0("net: don't allow CAP_NET_ADMIN to load non-netdev ke=
rnel modules")
> =A0 =A0 =A0 =A0so that we can add Stephen Hemminger's fix to handle i=
p6 tunnels
> =A0 =A0 =A0 =A0as well, which uses the MODULE_ALIAS_NETDEV() macro cr=
eated by
> =A0 =A0 =A0 =A0that change.

Yeah, that would have explained it. That said, if you are merging for
something like that, may I suggest actually starting off with

   git merge 8909c9ad8ff03611c9c96c9a92656213e4bb495b

that then actually makes the history itself also show the relationship
(you'd still have to write the commit message explaining why,
otherwise git will try to be "helpful" by making the merge commit
message be

   Merge commit '8909c9ad8ff03611c9c96c9a92656213e4bb495b'

which while _technically_ more useful and indicative of what you
wanted to do isn't actually any more readable than the one you have
now.

But the reason it would have been better is that it would literally
have made the git commit parenthood point to the commit you actually
care about.

Of course, since 'gitk' ends up highlighting the SHA1 pointers in the
commit message, even just mentioning it in the message is often almost
equivalent to having the parenthood be explicit. But it would show in
the actual history graph too, which I think would have been a good
thing.

Oh well. Water under the bridge. I think I'll try --no-ff this once,
despite my misgivings about the concept.

                Linus

[ The reason I don't like "--no-ff" is that it can cause endless "I'm
going to add my own merge message" wars where people want to write
their name in the snow, and then doing cross-merges doesn't ever
actually converge on a single end-result. Fast-forward merges means
that people merging back-and-forth will always end up converging.

But I guess the whole notion of "upstream" vs "downstream" is the
thing that should be considered to be the real way to avoid that, and
if a project cannot agree on what's upstream and what is downstream, I
suspect the project has deeper problems than a few extra merge
messages ;^) ]
