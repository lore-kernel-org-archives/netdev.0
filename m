From: David Laight <David.Laight@ACULAB.COM>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from
 atomic_t to refcount_t
Date: Mon, 20 Mar 2017 15:00:33 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB5570@AcuExch.aculab.com>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
	<20170318164759.GA23837@gondor.apana.org.au>
	<20170318.182121.439615057765380575.davem@davemloft.net>
	<20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
	<20170320131629.GA26405@gondor.apana.org.au>
	<063D6719AE5E284EB5DD2968C1650D6DCFFB5483@AcuExch.aculab.com>
	<20170320142807.mhu3xod2x2zzvego@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
Cc: "keescook@chromium.org" <keescook@chromium.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"ishkamiel@gmail.com" <ishkamiel@gmail.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"dwindsor@gmail.com" <dwindsor@gmail.com>,
	David Miller <davem@davemloft.net>,
	"elena.reshetova@intel.com" <elena.reshetova@intel.com>,
	'Herbert Xu' <herbert@gondor.apana.org.au>
To: 'Peter Zijlstra' <peterz@infradead.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170320142807.mhu3xod2x2zzvego@hirez.programming.kicks-ass.net>
Content-Language: en-US
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Peter Zijlstra
> Sent: 20 March 2017 14:28
> On Mon, Mar 20, 2017 at 02:10:24PM +0000, David Laight wrote:
> > On x86 the cpu flags from the 'lock inc/dec' could be used to reasonabl=
y
> > cheaply detect errors - provided you actually generate a forwards branc=
h.
>=20
> Note that currently there is no arch specific implementation. We could
> of course cure this.
>=20
> But note that the thing you propose; using the overflow flag, can only
> reasonably be done on PREEMPT=3Dn kernels, otherwise we have an incredibl=
e
> number of contexts that can nest.
>=20
> Sure; getting all starts aligned to double overflow is incredibly rare,
> but I don't want to be the one to have to debug that.

One overflow would set the overflow flag, you don't need both to fail.

In any case you can use the sign flag.
Say valid count values are -64k to -256 and 0 to MAXINT.
The count will normally be +ve unless the 'main free path'
has released the 64k references it holds.
If the sign bit is set after inc/dec the value is checked;=20
might valid, an error, or require the item be freed.

Ok assuming the items have reasonable lifetimes and have a nominal
'delete' function.

	David
