From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 22:44:12 +0300
Message-ID: <20070220194409.GB5590@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201738.19590.dada1@cosmosbay.com> <20070220165907.GB24930@2ka.mipt.ru> <200702201820.27095.dada1@cosmosbay.com> <20070220175550.GB26961@2ka.mipt.ru> <20070220181217.GA3401@2ka.mipt.ru> <f2b55d220702201113m12355e5ds584cede246d4728c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58150 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030370AbXBTTqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:46:10 -0500
Content-Disposition: inline
In-Reply-To: <f2b55d220702201113m12355e5ds584cede246d4728c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 11:13:50AM -0800, Michael K. Edwards (medwards.linux@gmail.com) wrote:
> On 2/20/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >And here are another ones which produce the same hash value.
> >Of course searching for pair for jhash('jhash is broken')
> >will require more steps, but it is doable.
> >
> >That means that if attacker has a full control over one host, it can
> >create a chain of maximum 4 entries in socket table (if jhash is used).
> >If it is udp, that means that attacker control addresses too without
> >syn cookies, which in turn means that below list can be increased to
> >infinite.
> 
> Evgeniy, you're not gettin' it.  Have you ever heard of a Poisson
> distribution?  That's what you have to aim for in a (bog-standard)
> hash table -- a hash function that scrambles the key space until you
> have a Poisson distribution in the hash buckets no matter whan pile of
> keys the attacker throws at you.  That's a "perfect" hash function in
> the statistician's sense (not a "perfect hash" function in the
> compiler designer's sense).  Yes there will be collisions, and they
> will start happening much earlier than you will think, if you have
> never heard of Poisson distributions before; that's called the
> "birthday problem" and it is a chestnut of a mathematical puzzle
> generally encountered by bright twelve-year-olds in extra-curricular
> math classes.  The only sensible way to deal with them is to use a
> better data structure -- like a 2-left hash (Google it) or something
> tree-ish.
> 
> That is not, however, what you're not getting.  What you're not
> getting is the use of a "salt" or "secret" or whatever you want to
> call it to turn a weak hash into an impenetrable defense against
> chosen-plaintext collision attacks.  You can run your PRNG until you
> slag your poor botnet's little CPUs searching for a set of tuples that
> collide in the same bucket on your test system-under-attack.  But they
> won't collide on mine, and they won't collide on Eric's, and they
> won't collide on yours the next time it's rebooted.  Because even a
> weak hash (in the cryptographer's sense) is good enough to scramble
> the key space radically differently with two different salts.  XOR
> doesn't cut it -- the salt will permute the buckets but not toss each
> one's contents up into the air to land in a bunch of different
> buckets.  But Jenkins does cut it, as discussed in the source code
> Eric pointed out to you.
> 
> Of course you don't change the salt except when resizing the hash
> (which is a dumb thing to do anyway, and a sure sign that a hash table
> is not the right data structure).  That would kinda defeat the purpose
> of having a hash table in the first place.
> 
> If you can't assimilate this and articulate it back to us in your own
> words instead of repeating "any hash that doesn't totally, utterly
> suck slows my meaningless artificial benchmark by 50%", you may not be
> the right person to design and implement a new RCU data structure in a
> kernel that thousands of us trust to withstand exposure to the open
> Internet to the best of a commodity processor's ability.

How I like personal insults - it is always fun to read about myself from
people who never knew me :)

I just shown a problem in jenkins hash - it is not how to find a
differnet input for the same output - it is a _law_ which allows to
break a hash. You will add some constant, and that law will be turned
into something different (getting into account what was written, it will
end up with the same law).

Using jenkins hash is equal to the situation, when part of you hash
chains will be 5 times longer than median square value, with XOR one
there is no such distribution.

Added somthing into permutations will not endup in different
distribution, since it is permutations which are broken, not its result
(which can be xored with something).

> Cheers,
> - Michael

-- 
	Evgeniy Polyakov
