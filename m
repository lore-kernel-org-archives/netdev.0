From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.17-rc5-mm3-lockdep -
Date: Mon, 12 Jun 2006 08:38:07 +0200
Message-ID: <20060612063807.GA23939@elte.hu>
References: <200606060250.k562oCrA004583@turing-police.cc.vt.edu>
	<44852819.2080503@gmail.com> <4485798B.4030007@s5r6.in-berlin.de>
	<4485AFB9.3040005@s5r6.in-berlin.de>
	<20060607071208.GA1951@gondor.apana.org.au>
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
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20060607071208.GA1951@gondor.apana.org.au>
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


* Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Tue, Jun 06, 2006 at 04:39:21PM +0000, Stefan Richter wrote:
> > 
> > BTW, the locking in -mm's net/unix/af_unix.c::unix_stream_connect() 
> > differs a bit from stock unix_stream_connect(). I see spin_lock_bh() in 
> > 2.6.17-rc5-mm3 where 2.6.17-rc5 has spin_lock().
> 
> Hi Ingo:
> 
> Looks like this change was introduced by the validator patch.  Any 
> idea why this was done? AF_UNIX is a user-space-driven socket so there 
> shouldn't be any need for BH to be disabled there.

yeah. I'll investigate - it's quite likely that sk_receive_queue.lock 
will have to get per-address family locking rules - right?

Maybe it's enough to introduce a separate key for AF_UNIX alone (and 
still having all other protocols share the locking rules for 
sk_receive_queue.lock) , by reinitializing its spinlock after 
sock_init_data()?

	Ingo
