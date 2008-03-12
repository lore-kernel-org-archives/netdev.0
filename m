From: Michael Monnerie <michael.monnerie@it-management.at>
Subject: Re: netatalk slow after system upgrade (possibly
	kernel problem?)
Date: Wed, 12 Mar 2008 03:26:47 +0100
Message-ID: <200803120326.47950@zmi.at>
References: <200801251255.48105@zmi.at>
	<20080126220051.d753266b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0333959364=="
Cc: netdev@vger.kernel.org, netatalk-admins@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netatalk-admins-bounces@lists.sourceforge.net>
In-Reply-To: <20080126220051.d753266b.akpm@linux-foundation.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/netatalk-admins>,
	<mailto:netatalk-admins-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=netatalk-admins>
List-Post: <mailto:netatalk-admins@lists.sourceforge.net>
List-Help: <mailto:netatalk-admins-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/netatalk-admins>,
	<mailto:netatalk-admins-request@lists.sourceforge.net?subject=subscribe>
Sender: netatalk-admins-bounces@lists.sourceforge.net
Errors-To: netatalk-admins-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============0333959364==
Content-Type: multipart/signed; boundary="nextPart1983773.zTW2VC7L4x";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1983773.zTW2VC7L4x
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

(full quote below, because this message was in January)

I did some new tests, see http://zmi.at/x/wire.delayack2.pcap
Dump from SUSE10.3, Apple client had delayed ACK set to 2 with
sysctl -w net.inet.tcp.delayed_ack=3D2, and also MacOS10.5 has this=20
problem. It was suggested I could have this problem:
http://www.helios.de/support/ti.phtml?110

On the same hardware, I can start the old SUSE10.0 at the same time in=20
parallel with the new SUSE10.3, both are virtual machines in VMware,=20
and the old machine is always fast and the new one always slow. From=20
the dump I would say it's the fault of MacOS - sometimes a very long=20
delay before an ACK. But then again, it's fast when copying to the old=20
SUSE linux box. Very strange.

On Sonntag, 27. Januar 2008 Andrew Morton wrote:
> (cc netdev)
>
> > On Fri, 25 Jan 2008 12:55:42 +0100 Michael Monnerie
> > <michael.monnerie@it-management.at> wrote: Dear lists,
> >
> > I've been spending a LOT of time trying to find out where's the
> > problem, but can't find it and therefore seek urgent help now. We
> > have the following system:
> >
> > Server with VMware server
> > -> VM running a webserver and netatalk
> > -> 2 other VMs not related
> >
> > The VM with netatalk was SUSE 10.0 with kernel 2.6.13-15.15-smp
> > (from SUSE), and things were pretty fun and quick. Then we upgraded
> > to SUSE 10.2 and now 10.3, where everything EXCEPT netatalk runs
> > perfect. Since this upgrade, Apple clients (MacOS X) now do READ
> > very very slowly (about 512KB/s over the gigabit LAN), while
> > writing to the server still is normal (>20MB/s). I've even retried
> > with the newest kernel 2.6.23.13, tried different
> > /proc/sys/net/ipv4/tcp_congestion_control (cubic, reno, bic, etc.)
> > and nothing helps. I've then tried to install Samba and found that
> > we have similar problems reading with it from MacOS clients. Now
> > I'm pretty sure it should be something with the linux kernel, but I
> > don't understand what.
> >
> > Here are the wireshark dumps in pcap format:
> > http://zmi.at/x/atalk-write-fast.pcap
> > -> you can see writing to the server (192.168.120.9) is normal and
> > fast
> >
> > http://zmi.at/x/atalk-read-slow.pcap
> > -> reading is horribly slow. Lots of "unknown", because of netatalk
> > or what?
> >
> > http://zmi.at/x/unknown-atalk.pcap
> > -> another dump while reading, you see "unknown" reads. I'm not
> > sure if it's just wireshark not understanding the packets or
> > netatalk.
> >
> > And trying with samba:
> > http://zmi.at/x/smb-read-slow.pcap
> > http://zmi.at/x/smb-write-quick.pcap
> > you can see that it's also slow.
> >
> > Now why did it work with the old 2.6.13 kernel? I still have that
> > old VM, and when I start it, it is always perfectly fast. Only
> > newer versions are slow. Can somebody give me a hint please?
>
> It would be interesting if this could be repeated on bare hardware,
> so we can eliminate the possibility that it is some weird interaction
> with vmware.



=2D-=20
// Michael Monnerie, Ing.BSc    -----      http://it-management.at
// Tel: 0676/846 914 666                      .network.your.ideas.
// PGP Key:         "curl -s http://zmi.at/zmi.asc | gpg --import"
// Fingerprint: AC19 F9D5 36ED CD8A EF38  500E CE14 91F7 1C12 09B4
// Keyserver: www.keyserver.net                   Key-ID: 1C1209B4

--nextPart1983773.zTW2VC7L4x
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQBH1z9nzhSR9xwSCbQRAsQSAJ0ZGetUp7v4EUndyUCg8c6uE60zVgCg4iaW
ihNChU3aiPva2Ah2fskujZk=
=hler
-----END PGP SIGNATURE-----

--nextPart1983773.zTW2VC7L4x--


--===============0333959364==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============0333959364==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Netatalk-admins mailing list
Netatalk-admins@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/netatalk-admins

--===============0333959364==--
