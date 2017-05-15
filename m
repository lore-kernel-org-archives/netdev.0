From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] kmod: don't load module unless req process has
 CAP_SYS_MODULE
Date: Mon, 15 May 2017 21:59:58 +0200
Message-ID: <20170515195958.GA16290@breakpoint.cc>
References: <20170514104537.GA29323@kroah.com>
 <87d1bbo81d.fsf@xmission.com>
 <20170515061059.GB28741@kroah.com>
 <20170515.095228.1483686375235860235.davem@davemloft.net>
 <CAF2d9jjdouSQYVk3kbWyOUEUe5b8S_Q6_Zx2WE_EBZB1cVeEvA@mail.gmail.com>
 <87r2zqj82a.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mahesh Bandewar
         =?utf-8?B?KOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL4=?=
         =?utf-8?B?4KSwKQ==?= <maheshb@google.com>,
        David Miller <davem@davemloft.net>, gregkh@linuxfoundation.org,
        mahesh@bandewar.net, mingo@kernel.org,
        linux-kernel@vger.kernel.org,
        linux-netdev <netdev@vger.kernel.org>, keescook@chromium.org,
        Eric Dumazet <edumazet@google.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87r2zqj82a.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman <ebiederm@xmission.com> wrote:
> If loading the conntrack module changes the semantics of packet
> processing when nothing is configured that is a bug in the conntrack
> module.

Thats the default behaviour since forever.

modprobe nf_conntrack_ipv4 -- module_init registers netfilter hooks
and starts doing connection tracking.

You might say 'its wrong' but thats how its been for over a decade.

If you have a suggestion on how to transition to a 'sane' behaviour,
then I'm all ears.

Note however, that conntrack doesn't need any configuration currently.

Its just there once module is loaded.
We could try hooking into nftables/iptables modules that use conntrack
info to make a decision, and thats what we do now in namespaces other
than init_net.

We still do it be default in iniet_net because someone could be
doing conntrack just for purpose of ctnetlink events (conntrack -E and
friends, or flow accouting and the like).
