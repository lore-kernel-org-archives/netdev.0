From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 17:04:54 +0100
Message-ID: <200702201704.55300.dada1@cosmosbay.com>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220151119.GA17326@2ka.mipt.ru> <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>,
	"David Miller" <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43695 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965289AbXBTQFF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:05:05 -0500
In-Reply-To: <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 20 February 2007 16:49, Michael K. Edwards wrote:
> On 2/20/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> > Jenkins _does_ have them, I showed tests half a year ago and in this
> > thread too. Actually _any_ hash has them it is just a matter of time
> > to find one.
>
> I think you misunderstood me.  If you are trying to DoS me from
> outside with a hash collision attack, you are trying to feed me
> packets that fall into the same hash bucket.  The Jenkins hash does
> not have to be artifact-free, and does not have to be
> cryptographically strong.  It just has to do a passable job of mixing
> a random salt into the tuple, so you don't know which string of
> packets to feed me in order to fill one (or a few) of my buckets.
> XORing salt into a folded tuple doesn't help; it just permutes the
> buckets.

Yes. I must say I had an attack like that some years ago on one particular 
server : Some tcp ehash chains had a length > 1000. I had to plug jenkin hash 
to stop the attack (thanks to David :), and thanks to oprofile to let me 
understand what was happening )

The attacker was controlling several thousand of zombies and was able to 
choose its src port (knowing its src ip addr) to target *one* particular hash 
bucket on my web server.

Each zombie was opening one tcp socket only, so a firewall could not detect 
them, they had a absolutely normal behavior.

XOR, combined with the 16 bits range of src port, permits a lot of easy 
guessing for the attacker (since it knows the ehash_size of target is a power 
of two...)

