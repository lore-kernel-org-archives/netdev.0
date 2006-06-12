From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.17-rc5-mm3-lockdep -
Date: Mon, 12 Jun 2006 16:41:22 +1000
Message-ID: <20060612064122.GA1101@gondor.apana.org.au>
References: <200606060250.k562oCrA004583@turing-police.cc.vt.edu>
	<44852819.2080503@gmail.com> <4485798B.4030007@s5r6.in-berlin.de>
	<4485AFB9.3040005@s5r6.in-berlin.de>
	<20060607071208.GA1951@gondor.apana.org.au>
	<20060612063807.GA23939@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	linux1394-devel@lists.sourceforge.net, Valdis.Kletnieks@vt.edu,
	Jiri Slaby <jirislaby@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@redhat.com,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	"David S. Miller" <davem@davemloft.net>, arjan@infradead.org
Return-path: <linux1394-devel-bounces@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20060612063807.GA23939@elte.hu>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=linux1394-devel>
List-Post: <mailto:linux1394-devel@lists.sourceforge.net>
List-Help: <mailto:linux1394-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux1394-devel>,
	<mailto:linux1394-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: linux1394-devel-bounces@lists.sourceforge.net
Errors-To: linux1394-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 08:38:07AM +0200, Ingo Molnar wrote:
> 
> yeah. I'll investigate - it's quite likely that sk_receive_queue.lock 
> will have to get per-address family locking rules - right?

Yes that's the issue.

> Maybe it's enough to introduce a separate key for AF_UNIX alone (and 
> still having all other protocols share the locking rules for 
> sk_receive_queue.lock) , by reinitializing its spinlock after 
> sock_init_data()?

This could work.  AF_UNIX is probably the only family that does not
interact with hardware.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
