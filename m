From: Thomas Graf <tgraf@suug.ch>
Subject: Re: SFQ: Reordering?
Date: Sat, 7 May 2005 01:02:03 +0200
Message-ID: <20050506230203.GI28419@postel.suug.ch>
References: <7bca1cb5050506145344d16b1e@mail.gmail.com> <427BEAAE.409@trash.net> <427BF3C4.1030105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Asim Shankar <asimshankar@gmail.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <427BF3C4.1030105@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Patrick McHardy <427BF3C4.1030105@trash.net> 2005-05-07 00:46
> Hmm wait, this is not so easy. We can't rehash by going over
> the buckets one by one. If we do so and we have a new clash of
> two flows previously contained in different buckets the packets
> will afterwards be sorted by flow in their new bucket. To retain
> fairness we need to iterate over all buckets containing packets
> and rehash them one packet per a bucket at a time. But this means
> we need lots of temporary storage to store the queues while
> rehashing. Can anyone thing of a better solution?

We can maintain a second hash table and switch a pointer over to the
new table but keep on dequeueing from the old one until it is empty.
Anyways, any such behaviour should be made optional via a rtnetlink
flag.
