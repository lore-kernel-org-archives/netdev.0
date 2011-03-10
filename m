From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Thu, 10 Mar 2011 15:49:40 -0800
Message-ID: <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
References: <20110310.153444.115930379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110310.153444.115930379.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 10, 2011 at 3:34 PM, David Miller <davem@davemloft.net> wro=
te:
>
> David S. Miller (3):
> =A0 =A0 =A0ipv4: Fix erroneous uses of ifa_address.
> =A0 =A0 =A0ipv6: Don't create clones of host routes.
> =A0 =A0 =A0Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

David, why do you keep on doing those broken back-merges?

It's the _one_ thing you keep on doing wrong, and I don't understand
it. Just the merge message you get should tell you that you're doing
something total SH*T.

Look at that commit message:

    Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

That is literally the WHOLE message. Ask yourself: is that commit
doing anything useful? Does the commit message explain what it is
doing, and why you are doing it?

And if not (and if you came to some other conclusion than "no" to
either of those questions, you should explain it), then why do you do
it? It sure doesn't help me: it just makes it harder for me to
see/follow the history (and if it's harder for me to see, then it's
harder for _others_ to see). There was no conflict (I double-checked),
and there was no explanation for why it would be done.

Now, I admit that it's a git usability bug: for normal "git commit",
git will _force_ you to write a message, and sadly, for merges, I made
it instead just do the message automatically. My bad. I designed it
for the kind of merges I do, where the the automatic merge message
actually tells you what the merge is all about. But for back-merges,
the automatic message is totally worthless, and it is DOUBLY worthless
when you do it the way you do it, namely from some local directory of
your own.

That's just STUPID. Look at that message once more, and ponder. What do=
es

  "Merge branch 'master' of /home/davem/src/GIT/linux-2.6/"

tell anybody? It's not even pointing to my repository, and you have
actively BROKEN the small amount of smarts (as admitted above, not
enough) that git does do normally, which is at least tell you where
the merge comes from. You broke it by fetching my repository into your
own anonymous tree, and then merging it from there, and thus the
automatic merge message lost sight of the fact that it was my upstream
tree, because you had made it your own random repo.

Grr. This has been going on for too long. Don't do it. Don't do random
backwards merges without explanations, and with the actual source data
removed.

We're _really_ good at doing commit messages, and the kernel commit
log should be a great example to other projects. But in the last week
or so, I've now _twice_ had to flame core developers for making
totally useless commit messages.

So don't do back-merges. And if you DO do back-merges, don't make the
commit message totally useless.

You can use either 'git commit --amend" to fix the message afterwards
and explain WHY you did the stupid thing, or you can just do "git pull
--no-commit" to not actually commit the merge and then write your
commit message as you do it. But preferably you shouldn't do the
back-merges at all.

                     Linus
