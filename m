From: Michael Monnerie <michael.monnerie@it-management.at>
Subject: Re: netatalk slow after system upgrade (possibly
	kernel problem?)
Date: Tue, 5 Feb 2008 16:26:19 +0100
Message-ID: <200802051626.25030@zmi.at>
References: <200801251255.48105@zmi.at>
	<20080126220051.d753266b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1728232680=="
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

--===============1728232680==
Content-Type: multipart/signed; boundary="nextPart1427539.7ROr4xtGff";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1427539.7ROr4xtGff
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

(I let full quote here for reference, my text is on the bottom)

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

I tested now on the same machine, outside of VMware: It is blazing fast,=20
just as it should be - kernel release 2.6.18.8-0.5-ZMI, where -ZMI=20
means I compiled the kernel myself. Still, it runs quick within the VM=20
with kernel 2.6.13-15.15-smp from SUSE 10.0, but slow with more recent=20
kernels (I couldn't test every combination of course).=20

I tried but cannot compile 2.6.13 within SUSE 10.3, it gives lots of=20
errors because libs changed.

It would be very nice to find the source of the problem. I uploaded the=20
kernel config options files onto my server for reference, HTH:

VMware with SUSE 10.0 and fast netatalk/samba:
http://zmi.at/x/config2.6.13-15.15.txt

VMware host, outside of VMware, also fast:
http://zmi.at/x/config2.6.18.8-host.txt

VMware with SUSE 10.2 and kernel 2.6.22-9-ZMI, slow:
http://zmi.at/x/config2.6.22.9-slow.txt

VMware with SUSE 10.3 and kernel 2.6.23.13-ZMI, slow:
http://zmi.at/x/config2.6.23.13-slow.txt

The problem seems to be somewhere between the kernel and VMware, but I=20
do not know what to do.

mfg zmi
=2D-=20
// Michael Monnerie, Ing.BSc    -----      http://it-management.at
// Tel: 0676/846 914 666                      .network.your.ideas.
// PGP Key:         "curl -s http://zmi.at/zmi.asc | gpg --import"
// Fingerprint: AC19 F9D5 36ED CD8A EF38  500E CE14 91F7 1C12 09B4
// Keyserver: www.keyserver.net                   Key-ID: 1C1209B4

--nextPart1427539.7ROr4xtGff
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4-svn0 (GNU/Linux)

iD8DBQBHqIAhzhSR9xwSCbQRAg4PAKC+0MrUHFSHBsmdDb7CsbqyfD7shACdHgNv
XjOdxUEO3qU+Nmxg4aXXNwc=
=hCIl
-----END PGP SIGNATURE-----

--nextPart1427539.7ROr4xtGff--


--===============1728232680==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--===============1728232680==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Netatalk-admins mailing list
Netatalk-admins@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/netatalk-admins

--===============1728232680==--
