From: Thomas Graf <tgraf@suug.ch>
Subject: Re: SFQ: Reordering?
Date: Sun, 8 May 2005 20:33:10 +0200
Message-ID: <20050508183310.GU28419@postel.suug.ch>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net> <20050506230203.GI28419@postel.suug.ch> <427BFB72.7080407@trash.net> <20050507005851.GK28419@postel.suug.ch> <427C19C3.5030304@trash.net> <20050508115100.GQ28419@postel.suug.ch> <427E3847.3050709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <427E3847.3050709@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <427E3847.3050709@trash.net> 2005-05-08 18:03
> Actually I was beginning to think you're right about having this
> feature optional. Paul McKenney's paper on SFQ states multiple times
> that perturbation can cause reordering if implemented the easy way,
> the Debian sfq manpage mentions this as well. So it appears to be a
> design-choice. Anyways, I suggest to make the decision when we know
> what the costs are.
> 
> BTW, this is the URL for the paper:
> http://rdrop.com/users/paulmck/paper/sfq.2002.06.04.pdf

Indeed, well I think it depends on the perturbation interval,
complexity and cost of the hashing function and the average
queue length so having a flag to toggle this feature is
certainly not a bad idea. Assuming a considerable queue length
and a perturbation level of 1-5 seconds it probably doesn't
make sense to rehash.

> I agree both make sense. Are you talking about run-time adjustable
> or compile-time adjustable? For SNAT it would also be nice to be
> able to use the original address, unfortunately this isn't possible
> anymore since we now drop the conntrack reference early.

We can compute the hash at ingress or just before we drop the
reference, store it in tc_classid and then use it at the egress
sfq. Needs some more thinking but should be doable.
