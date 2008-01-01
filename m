From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc6-mm1
Date: Tue, 1 Jan 2008 23:04:07 +1100
Message-ID: <20080101120406.GA27209@gondor.apana.org.au>
References: <20071222233056.d652743e.akpm@linux-foundation.org> <64bb37e0712230827m7d368e2l3174f3b4396d09c1@mail.gmail.com> <64bb37e0712281453y4aac82b7h7acc8ec314ca6e3e@mail.gmail.com> <20071228150746.42b3bbc0.akpm@linux-foundation.org> <64bb37e0712290851r6d41768dk270e47884713a3de@mail.gmail.com> <20071230013021.GA13603@gondor.apana.org.au> <64bb37e0712291934o77a3d365h56c9c31ac8437469@mail.gmail.com> <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@fieldses.org>, netdev@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>
To: Torsten Kaiser <just.for.lkml@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754243AbYAAMEh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <64bb37e0712311215x519b10e9kd51eb745b3b7290a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 31, 2007 at 09:15:19PM +0100, Torsten Kaiser wrote:
> 
> I then tried to "fix" it with this suspect.
> I changed "skb_release_all(dst);" back to "skb_release_data(dst);" in
> skb_morph() (net/core/skbuff.c).

Check /proc/net/snmp to see if you're getting any fragments, if not
then skb_morph shouldn't even be getting called.

> I'm now at 205 of 210 packages completed without a further hang. I
> also do not see an obvious memory leak.

In any case, I suspect the cause of your problem is that somebody
somewhere is doing a double-free on an skb.

Since you're the only person who can reproduce this, we really need
your help to track this down.  Since bisecting the mm tree is not
practical, you could start by checking whether the bug is in mm only
or whether it affects rc6 too.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
