From: "JaniD++" <djani22@dynamicweb.hu>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Fri, 31 Mar 2006 14:45:24 +0200
Message-ID: <01bf01c654c1$043c4d80$1600a8c0@dcccs>
References: <442BAC99.2090404@kernelpanic.ru> <20060330101218.GA2905@gondor.apana.org.au> <442BDD25.1060000@kernelpanic.ru> <20060331.011245.26474207.davem@davemloft.net> <442D0186.8090705@kernelpanic.ru> <20060331103956.GA12181@gondor.apana.org.au> <442D1B67.8000804@kernelpanic.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <davem@davemloft.net>, <jesse.brandeburg@intel.com>,
	<nipsy@bitgnome.net>, <jrlundgren@gmail.com>, <cat@zip.com.au>,
	<djani22@dynamicweb.hu>, <yoseph.basri@gmail.com>,
	<mykleb@no.ibm.com>, <olel@ans.pl>, <michal@feix.cz>,
	<chris@scorpion.nl>, <netdev@vger.kernel.org>,
	<jesse.brandeburg@gmail.com>, <E1000-devel@lists.sourceforge.net>,
	"\"Andi Kleen\"" <ak@suse.de>, "\"Jeff Garzik\"" <jgarzik@pobox.com>
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org


----- Original Message -----=20
From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>; <jesse.brandeburg@intel.com>=
;
<nipsy@bitgnome.net>; <jrlundgren@gmail.com>; <cat@zip.com.au>;
<djani22@dynamicweb.hu>; <yoseph.basri@gmail.com>; <mykleb@no.ibm.com>;
<olel@ans.pl>; <michal@feix.cz>; <chris@scorpion.nl>;
<netdev@vger.kernel.org>; <jesse.brandeburg@gmail.com>;
<E1000-devel@lists.sourceforge.net>; "Andi Kleen" <ak@suse.de>; "Jeff
Garzik" <jgarzik@pobox.com>
Sent: Friday, March 31, 2006 2:07 PM
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed..=
.


> Hello, Herbert Xu.
>
> On 31.03.2006 14:39 you said the following:
>
> > On Fri, Mar 31, 2006 at 02:16:38PM +0400, Boris B. Zhmurov wrote:
> >
> >>And xdelta tells, that e1000.ko was modified :)
> >
> >
> > Thanks for checking again.
> >
> > Anyway, it didn't take long to find another bug in the same area.
> > I'm afraid this driver does seem to be full of them :)
> >
> > It sets last_tx_tso in between computing the number of descriptors an=
d
> > calling e1000_tx_map.  This is bad because e1000_tx_map gets the wron=
g
> > value for last_tx_tso and therefore may corrupt memory for every TSO
> > packet when the ring is almost full.
> >
> > This bug exists on UP as well as SMP.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >
> > Please try this in conjunction with the previous patch.
> >
> > Cheers,
>
>
> David, Herbert - FYI. One of my colleague confirmed, that idea "bug
> reproducible only if there is more then one e1000 adapter onboard" is
> true. He has a 3 servers with double intel pro 1000 adapters, and that
> bug occurs. Also, he has 4 servers with double intel pro 1000 adapters
> onboard, but _only one_ of them is up. And there is no such messages in
> dmesg at all! Inetresting...

This is not an unique thing!

Only _one_ of my 2 equal NIC get this message

NETDEV WATCHDOG: eth0: transmit timed out
e1000: eth0: e1000_watchdog_task: NIC Link is Up 1000 Mbps Full Duplex

with the old 2.6.15.* e1000 driver!

Not the all e1000 chips ar really equal with the same P/N Number!

This can be hardware based problem, and needs workaround?

Cheers,



>
> --=20
> Boris B. Zhmurov
> mailto: bb@kernelpanic.ru
> "wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"
>
>  _____________ NOD32 1.584 (20031220) Inform=E1ci=F3 _____________
>
> Az =FCzenetet a NOD32 Antivirus System megvizsg=E1lta.
> http://www.nod32.hu
>
>



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting langua=
ge
that extends applications into web and mobile media. Attend the live webc=
ast
and join the prime developer group breaking into this new coding territor=
y!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D110944&bid=3D241720&dat=3D=
121642
