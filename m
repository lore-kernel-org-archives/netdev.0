From: Mark Smith <random@72616e646f6d20323030342d30342d31360a.nosense.org>
Subject: Re: [RFC PATCH] Change "local" route table preference from 0 to
 3fff, to permit send-to-self policy routing
Date: Thu, 24 Jun 2004 09:18:19 +0930
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040624091819.3f73012d.random@72616e646f6d20323030342d30342d31360a.nosense.org>
References: <20040618182505.195d76ba.random@72616e646f6d20323030342d30342d31360a.nosense.org>
	<20040618204529.GA3106@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20040618204529.GA3106@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Alexey,

On Sat, 19 Jun 2004 00:45:29 +0400
Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

Thanks for spending the time replying to me, I appreciate it.

> Hello!
> 
> > that problem. Something I'll look into further, unless somebody can tell
> > me that having a host reply its own ARP requests, even when received over
> > a real interface, isn't possible at all.
> 
> Sigh, do not you think that making undelatable local rule with preference 0
> was an easy decision. This kills most of coolness of policy making yet. :-)
> 
> Essentially, your patch becomes 100% legal after we kill the places
> where we ask "Is X.X.X.X our local address?". This thing with arp is one
> of many places when we have to do this to keep stack relatively coherent.
> We have several places where we do lookup directly in local table bypassing
> policy rules, because we just do not have enough information to look
> in right place.
> 

Are all those non-policy places where this "local" lookup occurs places where
only local traffic related functions occur ie. functions like ARP ? Or, in
other words, non-packet forwarding decision functions ?

In these places, does it just jump to rule 0 ? If this is the case, would it
be possible to modify them to jump to the specially designated "local"
table, using some other method than "local" always being rule 0, allowing
them to find out what the locally assigned addresses are, yet not relying on
the "local" table being rule 0 ?

> > kernel hacking, if there is a better way to change the "local" route table
> > preference, I'm all ears.
> 
> No, really. It is the best. Not made only as fool proof, because adding
> almost any rule before local one shuts down networking completely.
>

I can see how it is important to prevent people from killing off their
networking. On the other hand, I tend to take the position that if you
don't know what you are doing, you shouldn't be playing with it :-)

In this case, I think if you are "silly" enough to change the order of the
local table lookup, you should be "smart" enough to know the consequences, and
if necessary, develop a configuration to avoid them.

However, if my suggested patch or requested functionality would create an
internal inconsistency or operational flaw within the Linux networking stack,
then obviously it wouldn't be the right thing to do. I certainly don't know
enough to make that judgement. I'm sure you do :-)

Thanks again for getting back to me.

Regards,
Mark.
