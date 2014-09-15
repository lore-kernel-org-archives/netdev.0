From: Joe M <joe9mail@gmail.com>
Subject: Re: loading ip_vti breaks IPSec connection
Date: Mon, 15 Sep 2014 11:47:31 -0500
Message-ID: <20140915164731.GA12524@master>
References: <CAHjjW16qJgU+cf2-fowyJMRioc61Ko8KF65Qp5Npw9DsoF95VA@mail.gmail.com>
 <CADdy8Hqb-7Q3jShq1-NbUtwVW9XbC8eKYa5B0E8g1g6CMTHbVg@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="oC1+HKm2/end4ao3"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christophe Gouault <christophe.gouault@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f51.google.com ([209.85.219.51]:64809 "EHLO
	mail-oa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753184AbaIOQrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 12:47:37 -0400
Received: by mail-oa0-f51.google.com with SMTP id m1so2799582oag.10
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 09:47:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CADdy8Hqb-7Q3jShq1-NbUtwVW9XbC8eKYa5B0E8g1g6CMTHbVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--oC1+HKm2/end4ao3
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Content-Disposition: inline


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Christophe,

Thank you for responding.

> I never experienced such problem.

Can you please share your configuration?

Do you have "mark=3D" in ipsec.conf? Do you use iptables rules to set
the mark? What are your vti tunnel's ikey and okey values? How do the
vti tunnel's remote and local correspond to the values in ipsec.conf
(when the client's have different public ip's and subnets)?

I use a custom kernel (gentoo distro), and got the seed from
kernel-seeds.org. I am also attaching my kernel config (config.gz) if
you want to check it out.

uname -a
Linux master 3.16.2-dirty #89 SMP PREEMPT Sun Sep 14 14:30:59 CDT 2014
x86_64 Intel(R) Pentium(R) CPU G620 @ 2.60GHz GenuineIntel GNU/Linux

It is dirty as I have been trying to add printk's to figure out ip_vti
behaviour. I can also try tthe latest rc kernel if that is what you
are using.

> By the way, was your IPsec tunnel already established when you
> executed your first ping? the first packet that triggers an IKE
> negotiation is always lost.

Without loading ip_vti (and mark=3D in ipsec.conf), I can get the pings
to work through the IPSec tunnel. I think I am doing something wrong
with the vti setup. Not setting the mark, okey, ikey or iptables rules
properly.

I am also attaching the note I sent to Mr. Steffen looking for
help. It has my configuration and xfrm policy and state.

I am using strongswan 5.2.0. Below is the gentoo configuration of
strongswan, if it helps.

eix --exact strongswan
[I] net-misc/strongswan
     Available versions:  5.1.3 (~)5.2.0-r1{tbz2} {+caps +constraints
     curl debug dhcp eap farp gcrypt ldap mysql networkmanager
     +non-root +openssl pam pkcs11 sqlite strongswan_plugins_blowfish
     strongswan_plugins_ccm strongswan_plugins_ctr
     strongswan_plugins_gcm strongswan_plugins_ha
     strongswan_plugins_ipseckey +strongswan_plugins_led
     +strongswan_plugins_lookip strongswan_plugins_ntru
     strongswan_plugins_padlock strongswan_plugins_rdrand
     +strongswan_plugins_systime-fix strongswan_plugins_unbound
     +strongswan_plugins_unity +strongswan_plugins_vici
     strongswan_plugins_whitelist}
     Installed versions:  5.2.0-r1{tbz2}(09:08:20 AM 09/15/2014)(caps
     constraints ldap non-root openssl pam strongswan_plugins_led
     strongswan_plugins_lookip strongswan_plugins_systime-fix
     strongswan_plugins_unity strongswan_plugins_vici -curl -debug
     -dhcp -eap -farp -gcrypt -mysql -networkmanager -pkcs11 -sqlite
     -strongswan_plugins_blowfish -strongswan_plugins_ccm
     -strongswan_plugins_ctr -strongswan_plugins_gcm
     -strongswan_plugins_ha -strongswan_plugins_ipseckey
     -strongswan_plugins_ntru -strongswan_plugins_padlock
     -strongswan_plugins_rdrand -strongswan_plugins_unbound
     -strongswan_plugins_whitelist)
     Homepage:            http://www.strongswan.org/
     Description:         IPsec-based VPN solution focused on security
     and ease of use, supporting IKEv1/IKEv2 and MOBIKE

equery uses strongswan
[ Legend : U - final flag setting for installation]
[        : I - package is installed with flag     ]
[ Colors : set, unset                             ]
 * Found these USE flags for net-misc/strongswan-5.2.0-r1:
 U I
 + + caps                           : Use Linux capabilities library
 to control privilege=20
 + + constraints                    : Enable advanced X.509 constraint
 checking plugin.=20
 - - curl                           : Add support for client-side URL
 transfer library=20
 - - debug                          : Enable extra debug codepaths,
 like asserts and extra output. If you want to get meaningful
 backtraces see=20
                                      http://www.gentoo.org/proj/en/qa/back=
traces.xml=20
 - - dhcp                           : Enable server support for
 querying virtual IP addresses for clients from a DHCP server. (IKEv2
 only)=20
 - - eap                            : Enable support for the different
 EAP modules that is supported.=20
 - - farp                           : Enable faking of ARP responses
 for virtual IP addresses assigned to clients. (IKEv2 only)=20
 - - gcrypt                         : Enable dev-libs/libgcrypt plugin
 which provides 3DES, AES, Blowfish, Camellia, CAST, DES, Serpent and
 Twofish ciphers along with MD4, MD5 and=20
                                      SHA1/2 hash algorithms, RSA and
                                      DH groups 1,2,5,14-18 and
                                      22-24(4.4+). Also includes a
                                      software random number
                                      generator.=20
 + + ldap                           : Add LDAP support (Lightweight
 Directory Access Protocol)=20
 - - mysql                          : Add mySQL Database support
 - - networkmanager                 : Enable net-misc/networkmanager support
 + + non-root                       : Force IKEv1/IKEv2 daemons to
 normal user privileges. This might impose some restrictions mainly to
 the IKEv1 daemon. Disable only if you really require superuser privileges.
 + + openssl                        : Enable dev-libs/openssl plugin
 which is required for Elliptic Curve Cryptography (DH groups
 19-21,25,26) and ECDSA. Also provides 3DES, AES, Blowfish, Camellia,
 CAST, DES, IDEA and RC5 ciphers along with MD2, MD4, MD5 and SHA1/2
 hash algorithms, RSA and DH groups 1,2,5,14-18 and 22-24(4.4+)
 dev-libs/openssl has to be compiled with USE=3D"-bindist".=20
 + + pam                            : Add support for PAM (Pluggable
 Authentication Modules) - DANGEROUS to arbitrarily flip=20
 - - pkcs11                         : Enable pkcs11 support.
 - - sqlite                         : Add support for sqlite - embedded sql=
 database
 - - strongswan_plugins_blowfish    : Enable support for the blowfish plugi=
n.
 - - strongswan_plugins_ccm         : Enable support for the ccm plugin.
 - - strongswan_plugins_ctr         : Enable support for the ctr plugin.
 - - strongswan_plugins_gcm         : Enable support for the gcm plugin.
 - - strongswan_plugins_ha          : Enable support for the ha plugin.
 - - strongswan_plugins_ipseckey    : Enable support for the ipseckey plugi=
n.
 + + strongswan_plugins_led         : Enable support for the led plugin.
 + + strongswan_plugins_lookip      : Enable support for the lookip plugin.
 - - strongswan_plugins_ntru        : Enable support for the ntru plugin.
 - - strongswan_plugins_padlock     : Enable support for the padlock plugin.
 - - strongswan_plugins_rdrand      : Enable support for the rdrand plugin.
 + + strongswan_plugins_systime-fix : Enable support for the systime-fix pl=
ugin.
 - - strongswan_plugins_unbound     : Enable support for the unbound plugin.
 + + strongswan_plugins_unity       : Enable support for the unity plugin.
 + + strongswan_plugins_vici        : Enable support for the vici plugin.
 - - strongswan_plugins_whitelist   : Enable support for the whitelist plug=
in.


Thanks again and Sorry for the bother,
Joe


--TB36FDmn/VVEgNH/
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="config.gz"
Content-Transfer-Encoding: base64

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

--TB36FDmn/VVEgNH/
Content-Type: application/vnd.lotus-organizer
Content-Disposition: attachment; filename="note-for-vti-help.org"
Content-Transfer-Encoding: quoted-printable

=0AHello Steffen Klassert,=0A=0AVery sorry for this bother.=0A=0AI could no=
t figure out how vti works with ipsec and your patch was the=0Alatest to ip=
_vti.c. If you cannot help, please excuse me.=0A=0AI cannot get the vpn tra=
ffic to get on the vti tunnel. tcpdump on vti=0Adoes not show anything. I t=
hink the tunnel lookup code, for some=0Areason, is not able to use the "vti=
l" tunnel.=0A=0AThe pings worked fine if I remove the ip_vti and ip_tunnel =
modules,=0Athe "mark=3D1" from /etc/ipsec.conf and the iptables mangle rule=
s to=0Aset-mark.=0A=0AThis is with strongswan 5.2.0. Can you please help?=
=0A=0AThis is my setup on moon (master hostname)=0A=0Acat /etc/ipsec.conf=
=0A# /etc/ipsec.conf - strongSwan IPsec configuration file=0A=0Aconfig setu=
p=0A=0Aconn %default=0A        ikelifetime=3D60m=0A        keylife=3D20m=0A=
        rekeymargin=3D3m=0A        keyingtries=3D1=0A        keyexchange=3D=
ikev2=0A        mobike=3Dno=0A=0Aconn master-bnglr=0A        leftid=3D"C=3D=
CH, O=3DstrongSwan, CN=3Dmaster"=0A        leftcert=3DmasterCert.der=0A    =
    left=3D192.168.0.11=0A        leftsubnet=3D192.168.0.0/24=0A        rig=
htid=3D"C=3DCH, O=3DstrongSwan, CN=3Dbnglr"=0A        right=3D%any=0A      =
  rightsubnet=3D192.168.1.0/24=0A        auto=3Dadd=0A        mark=3D1=0A=
=0A=0Asudo cat /etc/ipsec.secrets=0A# /etc/ipsec.secrets - strongSwan IPsec=
 secrets file=0A=0A  : RSA masterKey.der=0A=0A=0Asudo ip tunnel list=0Avtil=
: ip/ip  remote 192.168.1.232  local 192.168.0.11  ttl inherit ikey 0  okey=
 1=0Aip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0=
=0A=0Asudo ip route list=0Adefault via 192.168.0.1 dev enp4s0  metric 202=
=0A127.0.0.0/8 dev lo  scope host=0A192.168.0.0/24 dev enp4s0  proto kernel=
  scope link  src 192.168.0.11=0Ametric 202=0A192.168.1.0/24 dev vtil  scop=
e link=0A=0A=0Asudo ip xfrm policy=0Asrc 192.168.1.0/24 dst 192.168.0.0/24=
=0A        dir fwd priority 2883=0A        mark 1/0xffffffff=0A        tmpl=
 src <bnglr public ip> dst 192.168.0.11=0A                proto esp reqid 2=
 mode tunnel=0Asrc 192.168.1.0/24 dst 192.168.0.0/24=0A        dir in prior=
ity 2883=0A        mark 1/0xffffffff=0A        tmpl src <bnglr public ip> d=
st 192.168.0.11=0A                proto esp reqid 2 mode tunnel=0Asrc 192.1=
68.0.0/24 dst 192.168.1.0/24=0A        dir out priority 2883=0A        mark=
 1/0xffffffff=0A        tmpl src 192.168.0.11 dst <bnglr public ip>=0A     =
           proto esp reqid 2 mode tunnel=0Asrc 0.0.0.0/0 dst 0.0.0.0/0=0A  =
      socket in priority 0=0Asrc 0.0.0.0/0 dst 0.0.0.0/0=0A        socket o=
ut priority 0=0Asrc 0.0.0.0/0 dst 0.0.0.0/0=0A        socket in priority 0=
=0Asrc 0.0.0.0/0 dst 0.0.0.0/0=0A        socket out priority 0=0Asrc ::/0 d=
st ::/0=0A        socket in priority 0=0Asrc ::/0 dst ::/0=0A        socket=
 out priority 0=0Asrc ::/0 dst ::/0=0A        socket in priority 0=0Asrc ::=
/0 dst ::/0=0A        socket out priority 0=0A=0Asudo ip xfrm state=0Asrc 1=
92.168.0.11 dst <bnglr public ip>=0A        proto esp spi 0xc3b23fb1 reqid =
2 mode tunnel=0A        replay-window 32 flag af-unspec=0A        mark 1/0x=
ffffffff=0A        auth-trunc hmac(sha1) 0x33f17d71abbc9ccdbef83ecba9e1c071=
1c3767a0 96=0A        enc cbc(aes) 0xe790b24d9e9f71aec28f8ed00013f411=0A   =
     encap type espinudp sport 4500 dport 8993 addr 0.0.0.0=0Asrc <bnglr pu=
blic ip> dst 192.168.0.11=0A        proto esp spi 0xc8bcf9b0 reqid 2 mode t=
unnel=0A        replay-window 32 flag af-unspec=0A        mark 1/0xffffffff=
=0A        auth-trunc hmac(sha1) 0xb780288b0cf20aa7f010552837cc03a04e29198a=
 96=0A        enc cbc(aes) 0xd0db2ec7e9bb83cbc6a9d20feb6eab49=0A        enc=
ap type espinudp sport 8993 dport 4500 addr 0.0.0.0=0A=0A=0AI tried setting=
 the mangle rules to set-mark but that did not help. I=0Acould not find any=
 more documentation.=0A=0AThanks again and Sorry for the bother,=0AJoe=0A
--TB36FDmn/VVEgNH/--

--oC1+HKm2/end4ao3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJUFxgjAAoJENvmPC7PRKkI3+UP/iPNIhy8oT5WXYsg8AOicgqs
8wtmV5ZlOMiJbPEOioldaLasYJf4uUe1SGMFqvMK/3rh7U5N6FZri1KpkQbLeyGc
/jvBDcPxWvMOuWpuH4ZBjhW53qDI+aK5ruf++OsroYcvkEhh/n2oReauElT6x0iN
lPnTU8gxPOESH3YdB9lO42s4cN2H7SDQCCMXAox4yyWxsgiDEcMWuyO9m5ZuTmje
gGAe+vlpr84efMXlU3S/bJEtRnmSJr9f4rvW0yVw6maJCtd0YirtJqQTXPAnA6BO
DfZHGHFa9SMCJGiDidX/+txlDa8Skg7ZjVPx3AYirORuWY80pM6QGgUA0K/T6u8p
ZdHWOE+TtDikUzNx/nnN86C+QAgm+I3EKDarnuxyajtuCm/T6tUg4Ud3IigOztBL
F05XTJkzg1KEf4k3Fm8ZoikDO0lhsXPJhS2eKygQWc0jm5WBUeSJoVsYr7CzgwwH
rW96Et6gtXG1C1B48/q1hp3ntpyi8pK+9Eo93MkOZ22WlSnzNmPLPuJMa4zHlg9Z
f3LRn2FVp4GjIJhXSXSillUtf37zUMBvDeooRr35zWcvnPiF2JjOVA9fdzwA6f4Y
24t39bZYKj+/ILJghQaSC9sWlQjOXY2yL/rFnOsGOSN0j0Ia5LB7E3piZfGO8k1a
2T+j3eitrOUgjljyDNKa
=U8Wf
-----END PGP SIGNATURE-----

--oC1+HKm2/end4ao3--
