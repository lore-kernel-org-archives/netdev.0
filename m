From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net PATCH] fib_trie: Fix trie balancing issue if new node
 pushes down existing node
Date: Fri, 12 Dec 2014 17:05:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0BEDD@AcuExch.aculab.com>
References: <20141211054815.1357.36977.stgit@ahduyck-vm-fedora20>
	<20141211.213216.1630491264342423219.davem@davemloft.net>
 <20141212.105425.2023800747122061277.davem@davemloft.net>
 <548B132B.5000606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexander Duyck' <alexander.duyck@gmail.com>,
	David Miller <davem@davemloft.net>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45993 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1030555AbaLLRGk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2014 12:06:40 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12384-10 for <netdev@vger.kernel.org>;
 Fri, 12 Dec 2014 17:06:31 +0000 (GMT)
In-Reply-To: <548B132B.5000606@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck
...
> >> One has to be mindful with this code that what it's doing now might
> >> be intentional.  For example, it might be doing things this way
> >> on purpose in order to minimize rebalancing during route flaps.
> >>
> >> Barring anything like that, I think your change is fine.
> > Alex, in case it isn't clear, I'm hoping that you might have some
> > thoughts on this aspect of your changes. :)
> 
> Route flaps should at most trigger an inflate without a deflate due to
> the way the resize logic works.  If this occurs often it would be useful
> since then there would already be space in the tree for the next time
> around.

One way to deal with 'flapping' is to leave deleted items in the tree
(marked so they won't be used).
Deleted entries do need to be garbage collected at some point.
Doing so during insert is more than adequate, and possibly only for
nodes that are traversed while processing the insert itself
(and maybe only is the ratio of valid to invalid entries is low).

This might also mean that you don't need to actively run any timeouts.
Timed out entries just stay put - marked invalid by their timestamp.

	David
