From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Thu, 1 Sep 2011 10:13:05 -0400
Message-ID: <20110901141304.GA2580@tuxdriver.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
 <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
 <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
 <4E5C3B47.1050809@freedesktop.org>
 <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com>
 <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com>
 <4E5CEC79.3090802@freedesktop.org>
 <9BB251C1-A211-486D-A717-59149AC3A709@gmail.com>
 <4E5E36EE.8080501@freedesktop.org>
 <CAB=NE6Wj4BxSjZmTOg9EFMcJ+H0RBZE4q8+6DB3x8qP=r42yNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6Wj4BxSjZmTOg9EFMcJ+H0RBZE4q8+6DB3x8qP=r42yNQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 31, 2011 at 01:50:48PM -0700, Luis R. Rodriguez wrote:
> On Wed, Aug 31, 2011 at 6:28 AM, Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org> wrote:

> > such as wireless, or even possibly modern broadband with
> > PowerBoost, classic RED or similar algorithms that do not take the
> > buffer drain rate cannot possibly hack it properly.
> 
> Understood, just curious if anyone has tried a Minstrel approach.

FWIW, eBDP and the related algorithms from Tianji Li's paper are
philosophically similar to minstrel.  They depend on measuring recent
conditions and modifying the current queue length accordingly.

	http://www.hamilton.ie/tianji_li/buffersizing.pdf

The hack I added in debloat-testing is based on my understanding
of eBDP.  It timestamps the SKBs when they are handed to the driver
for Tx and then checks the timestamp when the SKB is orphaned.  It is
a bit crude and is an abuse of the skb_orphan API.  Also while it
accounts for the 802.11e queues separately, it doesn't account for
802.11n aggregation.  Still, it seems to improve latency w/o hugely
impacting throughput in at least some environments -- YMMV!

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
