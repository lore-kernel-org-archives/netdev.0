From: Patrick McHardy <kaber@trash.net>
Subject: Re: SFQ: Reordering?
Date: Sun, 08 May 2005 18:03:19 +0200
Message-ID: <427E3847.3050709@trash.net>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net> <20050506230203.GI28419@postel.suug.ch> <427BFB72.7080407@trash.net> <20050507005851.GK28419@postel.suug.ch> <427C19C3.5030304@trash.net> <20050508115100.GQ28419@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050508115100.GQ28419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> * Patrick McHardy <427C19C3.5030304@trash.net> 2005-05-07 03:28
> 
>>You stated my goal precisely :) I know many people set the interval
>>to too low values, but because of the tight limits, it shouldn't be
>>very expensive anyways. Table switching OTOH would introduce frequently
>>occuring unfairness, and the time to work through a full table is
>>a lot longer, especially in the environments where SFQ is used.
> 
> I think you are right on this so forget about my thought.

Actually I was beginning to think you're right about having this
feature optional. Paul McKenney's paper on SFQ states multiple times
that perturbation can cause reordering if implemented the easy way,
the Debian sfq manpage mentions this as well. So it appears to be a
design-choice. Anyways, I suggest to make the decision when we know
what the costs are.

BTW, this is the URL for the paper:
http://rdrop.com/users/paulmck/paper/sfq.2002.06.04.pdf

> Maybe as
> an additional input it might be worth mentioning that I have patches
> ready to a) make the sfq depth adjustable and b) hash algorithm
> selection to a few builtin ones and additional to read theh hash
> from tc_classid set by an action. A real world example where this
> is useful is for routers primarly doing SNAT without any own local
> traffic where hashing algorithm primarly based on the source port
> makes a lot more sense.

I agree both make sense. Are you talking about run-time adjustable
or compile-time adjustable? For SNAT it would also be nice to be
able to use the original address, unfortunately this isn't possible
anymore since we now drop the conntrack reference early.

Regards
Patrick
