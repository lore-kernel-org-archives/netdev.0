From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 2.6.24-rc5-mm1 -- INFO: possible circular
	locking dependency	detected -- pm-suspend/5800 is trying to
	acquire lock
Date: Tue, 18 Dec 2007 15:57:06 +0100
Message-ID: <1197989826.4885.169.camel@johannes.berg>
References: <a44ae5cd0712180603v2a37023dj714a8500c14c08de@mail.gmail.com>
	<1197986886.4885.156.camel@johannes.berg>
	<a44ae5cd0712180641n15ceae8bp977efe9a5b45e6bc@mail.gmail.com>
	(sfid-20071218_144150_051683_83D9589E)
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0838801601=="
Cc: Len Brown <len.brown@intel.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	ipw3945-devel@lists.sourceforge.net,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <ipw3945-devel-bounces@lists.sourceforge.net>
In-Reply-To: <a44ae5cd0712180641n15ceae8bp977efe9a5b45e6bc@mail.gmail.com>
	(sfid-20071218_144150_051683_83D9589E)
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ipw3945-devel>
List-Post: <mailto:ipw3945-devel@lists.sourceforge.net>
List-Help: <mailto:ipw3945-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ipw3945-devel>,
	<mailto:ipw3945-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ipw3945-devel-bounces@lists.sourceforge.net
Errors-To: ipw3945-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============0838801601==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="=-hRdJylCaQ45BEXgq2z/I"


--=-hRdJylCaQ45BEXgq2z/I
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Sorry.  GMail doesn't support sending unwrapped text, as far as I can
> tell.  I will send the log segment to you as an attachment.  Also,
> when I sent my .config inline to Andrew recently, it tripped his spam
> filter.  I'll attach it as well.

Thanks. This is a bug in iwlwifi.

The problem is actually another case where my workqueue debugging with
lockdep is triggering a warning :))

Here's the thing:

iwl3945_cancel_deferred_work does=20

cancel_delayed_work_sync(&priv->init_alive_start);

(which is the "(&(&priv->init_alive_start)->work)" lock)

but it is called from within a locked section of
mutex_lock(&priv->mutex); (locked from iwl3945_pci_suspend)

On the other hand, the task that runs from the init_alive_start
workqueue is iwl3945_bg_init_alive_start() which will lock the same
mutex.

So the deadlock condition is that you can be in
cancel_delayed_work_sync() above while the mutex is locked, and be
waiting for iwl_3945_bg_init_alive_start() which tries to lock the
mutex.

johannes

--=-hRdJylCaQ45BEXgq2z/I
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR2ffwaVg1VMiehFYAQJ1sw//d3WjOmOMlwroYtDEVaG86jP8YfTS3RLg
+HDmGC+xXZAqGSJK1/g02/oexaMSJUKAXctNcL7L7jc0gIiPRCA3UDkuMQAZG7Iw
3hTwb7vxZL5/cwdqwEeEbJuor2yAond8o5L+w1480HMCpsXMaUyc6oCv39hxlfVL
RYcAmfBpKYdh68Y9NkASaabJLQjgXwIFGYmFpigOghjWITZCH19+mdLoRMcbG9bE
He3DfTNR0ShgvJT0C0KUPEpW0XnNODc+/iOdmxJknAK3FYtlH1gFHPNfOw4dKpMA
cFmEgM3IxhWDRKuuI1ZtPJyPBIHGxXwBZRP+vPx6jSYZYhVSP1VQ+xmfcdDr/ggp
C4yFemYiWmJFzdqjPndVWJnjJDO4cgmL1SG9uDaxLF14OCAU6Vz5LkmwDEPJYj/Z
ZdSSbIKZjbmME+5G8Jl1ek+WO93V+X6mhS46nc1ZpBw5XxFueba+UjkC6oan0TeJ
N1ciKOTooSYfbZSbla9UaAiQvPizawPJAuSeTji4pa8pAQ2+57b3dFoFCPGAoaj3
Qt4lB/2XlufUOQ5d5VVJde39d7iYbgrA8TCPGo76n0NY3vF6atApLScqzdKPYma7
JDXKclIwhw8MTR1iLtztA8YuN8cUD7JDdGGctZyJqaJrS7SLq1xkuH6fMXsDtuIf
csgW708C/rg=
=L9ty
-----END PGP SIGNATURE-----

--=-hRdJylCaQ45BEXgq2z/I--



--===============0838801601==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services
for just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
--===============0838801601==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Ipw3945-devel mailing list
Ipw3945-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/ipw3945-devel

--===============0838801601==--
