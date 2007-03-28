From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Established connections hash function
Date: Wed, 28 Mar 2007 14:45:06 +0400
Message-ID: <20070328104505.GA18748@2ka.mipt.ru>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON> <p73lkhi6aj7.fsf@bingen.suse.de> <EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON> <200703281129.43783.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: nikb@webmaster.com, netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:48521 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934017AbXC1KpV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 06:45:21 -0400
Content-Disposition: inline
In-Reply-To: <200703281129.43783.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 28, 2007 at 11:29:43AM +0200, Andi Kleen (ak@suse.de) wrote:
> > > But I think it can be mostly ignored.
> > 
> >     With all due respect, it cannot. An attacker with a small-sized botnet 
> > (which is ~250 hosts) can create chains that contain well in excess of 3000 
> > items. 
> 
> Most likely they can also easily generate enough latency data to crack any simple
> hash function then.

Jenkins hash is far from being simple to crack, although with some
knowledge it can be done faster.

SHA or something else is essentially the same, except it has different
set of rounds - we only hashes 3 32 bit values, so Jenkins result is
really good.

For the hash tables it is a good solution, but we can move further.
I created multidimensional trie with that problem in mind, but it looks
like right now it is not absolutely required solution - I will continue
to work on it to check if we can be faster than properly sized hash
table with additional trie allocation overhead, but likely I should not
force people include it as is, only for information I think.

> -Andi

-- 
	Evgeniy Polyakov
