From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 0/11] use ether_addr_equal_64bits
Date: Fri, 17 Jan 2014 23:43:15 +0100
Message-ID: <20140117224315.GC13930@amd.pavel.ucw.cz>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
	<20140117212410.GA13930@amd.pavel.ucw.cz>
	<52D9A85E.8070306@rempel-privat.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Julia Lawall <Julia.Lawall@lip6.fr>, ath9k-devel@lists.ath9k.org
To: Oleksij Rempel <linux@rempel-privat.de>
Return-path: <ath9k-devel-bounces@lists.ath9k.org>
Content-Disposition: inline
In-Reply-To: <52D9A85E.8070306@rempel-privat.de>
List-Unsubscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=unsubscribe>
List-Archive: <http://lists.ath9k.org/pipermail/ath9k-devel>
List-Post: <mailto:ath9k-devel@lists.ath9k.org>
List-Help: <mailto:ath9k-devel-request@lists.ath9k.org?subject=help>
List-Subscribe: <https://lists.ath9k.org/mailman/listinfo/ath9k-devel>,
	<mailto:ath9k-devel-request@lists.ath9k.org?subject=subscribe>
Sender: ath9k-devel-bounces@lists.ath9k.org
Errors-To: ath9k-devel-bounces@lists.ath9k.org
List-Id: netdev.vger.kernel.org

On Fri 2014-01-17 23:02:06, Oleksij Rempel wrote:
> Am 17.01.2014 22:24, schrieb Pavel Machek:
> > On Mon 2013-12-30 19:14:56, Julia Lawall wrote:
> >> Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
> >> used when each argument is an array within a structure that contains at
> >> least two bytes of data beyond the array.
> > 
> > I mean, yes, it is probably faster, and yes, most structures probably
> > contain two more bytes, but... is the uglyness worth the speedup? I'd
> > say this should not be done except in very time-critical places...
> 
> This code run on every received beacon, almost on every wifi driver (If
> i understand what you mean.)

That does not look like "sufficiently often" to me. Can you measure
the improvement at least in some microbenchmark? Is there even
theoretical chance to get one?

You are comparing few bytes, number of cacheline accesses stays same,
there is likely _0_ speedup. And even if you saved 1T, that will be
compeletely lost in the noise.

In some kind of routing code, cache-hot... maybe it would make
sense. But once per interrupt?

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
