From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] tcf_bind_filter failure handling
Date: Mon, 13 Dec 2004 20:32:28 +0100
Message-ID: <20041213193228.GG8493@postel.suug.ch>
References: <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch> <41917330.6090002@trash.net> <20041212175736.GA8493@postel.suug.ch> <41BC8819.7040501@trash.net> <20041213165302.GE8493@postel.suug.ch> <41BDDB5A.9000907@trash.net> <20041213185203.GF8493@postel.suug.ch> <1102965823.1075.14.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1102965823.1075.14.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1102965823.1075.14.camel@jzny.localdomain> 2004-12-13 14:23
> 
> When/why would binding fail? tcindex is an exception.
> I dont see binding as having any contribution to the error path.
> Additional locking is not advisable. The binding could happen while
> traffic is running.

The binding fails if the class does not exist at the time the classifier
is loaded. The original implementation regarded binding optional to do
the classid -> class lookup only once while loading instead of everytime
classify() returns. tcindex does not do so because it uses the class
field to determine whether a perfect hash bucket is used or not. I
changed it to check classid || police || action because one of them is
definitely defined and enforced as a requirement during validation.

The locking i mentioned was not a spinlock but rather a refcnt++ in the
class intended to be bound later during change, i.e. to ensure a qdisc
destroy rcu callback can't destroy the class while we're about to bind
to it. But since we agree on changing tcindex this is not an issue and
nothing will change.

Sorry for the confusion, my word choice was rather bad for such a
simple issue and produced more confusion than results.
