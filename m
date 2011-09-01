From: Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org>
Subject: Re: BQL crap and wireless
Date: Thu, 01 Sep 2011 11:08:10 -0400
Message-ID: <4E5F9FDA.3020901@freedesktop.org>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com> <CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com> <CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com> <4E5C3B47.1050809@freedesktop.org> <CA+mtBx-j_+mrNpntR7CfYOromDnM-ZGzvebpUCjC8Qf14X6u9g@mail.gmail.com> <CAJ-Vmonwur-SXddNwjPEidCMqes+PwbRWFBddfdwTp2jOMu64g@mail.gmail.com> <4E5CEC79.3090802@freedesktop.org> <9BB251C1-A211-486D-A717-59149AC3A709@gmail.com> <4E5E36EE.8080501@freedesktop.org> <CAB=NE6Wj4BxSjZmTOg9EFMcJ+H0RBZE4q8+6DB3x8qP=r42yNQ@mail.gmail.com> <20110901141304.GA2580@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew McGregor <andrewmcgr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Adrian Chadd <adrian-h+KGxgPPiopAfugRpC6u6w@public.gmane.org>,
	Tom Herbert <therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Matt Smith <smithm-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Kevin Hayes <hayes-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>,
	Derek Smithies <derek-Rd3uoDiDeHXJKwlM9GxbOw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110901141304.GA2580-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/01/2011 10:13 AM, John W. Linville wrote:
> On Wed, Aug 31, 2011 at 01:50:48PM -0700, Luis R. Rodriguez wrote:
>> On Wed, Aug 31, 2011 at 6:28 AM, Jim Gettys <jg-CC+yJ3UmIYqDUpFQwHEjaQ@public.gmane.org> wrote:
>> such as wireless, or even possibly modern broadband with
>> PowerBoost, classic RED or similar algorithms that do not take the
>> buffer drain rate cannot possibly hack it properly.
>> Understood, just curious if anyone has tried a Minstrel approach.
> FWIW, eBDP and the related algorithms from Tianji Li's paper are
> philosophically similar to minstrel.  They depend on measuring recent
> conditions and modifying the current queue length accordingly.
>
> 	http://www.hamilton.ie/tianji_li/buffersizing.pdf
>
> The hack I added in debloat-testing is based on my understanding
> of eBDP.  It timestamps the SKBs when they are handed to the driver
> for Tx and then checks the timestamp when the SKB is orphaned.  It is
> a bit crude and is an abuse of the skb_orphan API.  Also while it
> accounts for the 802.11e queues separately, it doesn't account for
> 802.11n aggregation.  Still, it seems to improve latency w/o hugely
> impacting throughput in at least some environments -- YMMV!
>
Certainly eBDP *sort of* works for me; I see somewhat more variation
(jitter) than I'd like, but at least latencies are at least somewhat
controlled and I've not seen performance (throughput) problems.  This is
on an Intel chipset.

Tanji Li's work and eBDP came to our attention after a conversation I
had with Van at the beginning of this year; Van send me a pointer to it
with the comments:

"As I said on the phone I think there's an easier, more robust way to accomplish the same
thing but they have running code and I don't."


But we've not had time to do any systematic testing on eBDP yet and the
implementation needs more work before it should go upstream.

About the time we were thinking of starting that testing, it became
clear that getting aggregation working better was pretty essential to
validating any results.  I'm looking forward to trying eBDP with the
revised Ath9k driver as soon as they get put into a single pool.  And if
Kathleen and Van can get a "RED Light" they are happy with, that will be
fun to try as well.
                                - Jim






--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
