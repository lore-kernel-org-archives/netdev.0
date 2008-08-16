From: =?ISO-8859-1?Q?D=E2niel?= Fraga <fragabr@gmail.com>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Fri, 15 Aug 2008 23:15:38 -0300
Message-ID: <20080815231538.7999c017@tux>
References: <Pine.LNX.4.64.0808081256560.4551@wrl-59.cs.helsinki.fi>
	<20080811.144421.234396007.davem@davemloft.net>
	<200808120946.19459.thomas.jarosch@intra2net.com>
	<20080812.011822.155249871.davem@davemloft.net>
	<20080812144309.7d62fd86@tux>
	<Pine.LNX.4.64.0808122044450.16105@wrl-59.cs.helsinki.fi>
	<20080813145310.0c1e534c@tux>
	<Pine.LNX.4.64.0808132108480.18807@wrl-59.cs.helsinki.fi>
	<20080815013407.4a594288@tux>
	<Pine.LNX.4.64.0808150939270.23522@wrl-59.cs.helsinki.fi>
	<20080815183511.1c81be23@tux>
	<Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, thomas.jarosch@intra2net.com,
	billfink@mindspring.com, Netdev <netdev@vger.kernel.org>,
	Patrick Hardy <kaber@trash.net>, sr@securenet.de,
	netfilter-devel@vger.kernel.org, kadlec@blackhole.kfki.hu
To: "Ilpo =?ISO-8859-1?Q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0808160039230.6911@wrl-59.cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 16 Aug 2008 01:06:55 +0300 (EEST)
"Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Ok. I hope it will still reproduce with tcpdump running... Btw, doing=
 cat=20
> /proc/net/tcp during the stall wouldn't be a bad idea (in addition to=
=20
> tcpdumping it). Also please let the tcpdumps run long enough if the s=
tall=20
> persists, something like 15mins doesn't hurt because there are large=20
> timer values possibly involved.

	Hi, I did the following:

fraga@tux ~/src$ cat /proc/net/tcp=20
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when
retrnsmt   uid  timeout inode 0: 00000000:0DA5 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 2912 1
ffff81007ea28000 299 0 0 2 -1 1: 00000000:23AA 00000000:0000 0A
00000000:00000000 00:00000000 00000000   501        0 6586 1
ffff8100614e1e00 299 0 0 2 -1 2: 00000000:1F4A 00000000:0000 0A
00000000:00000000 00:00000000 00000000   501        0 6164 1
ffff8100614e2400 299 0 0 2 -1 3: 00000000:0CEA 00000000:0000 0A
00000000:00000000 00:00000000 00000000 12347        0 3205 1
ffff81007ea29800 299 0 0 2 -1 4: 00000000:008B 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 3191 1
ffff81007e921800 299 0 0 2 -1 5: 00000000:1770 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 3454 1
ffff81007ea29e00 299 0 0 2 -1 6: 00000000:0015 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 2860 1
ffff81007e920600 299 0 0 2 -1 7: 00000000:0016 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 2507 1
ffff81007e920000 299 0 0 2 -1 8: 00000000:0077 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 2861 1
ffff81007e920c00 299 0 0 2 -1 9: 00000000:0019 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 3029 1
ffff81007ea29200 299 0 0 2 -1 10: 00000000:01BD 00000000:0000 0A
00000000:00000000 00:00000000 00000000     0        0 3190 1
ffff81007e921200 299 0 0 2 -1 11: 0200A8C0:D8B5 4009BCCD:1446 01
00000000:00000000 00:00000000 00000000   501        0 6187 1
ffff8100614e4200 36 3 20 4 3 12: 0200A8C0:C77C D4E133C9:C5CF 01
00000000:00000000 00:00000000 00000000   501        0 7593 1
ffff810049008c00 39 3 24 4 -1 13: 0200A8C0:DD6A 21250440:0747 01
00000000:00000000 00:00000000 00000000   501        0 17613 1
ffff81007e927200 71 3 0 4 -1 14: 0200A8C0:9D7D B9B5A342:13BA 01
00000000:00000000 00:00000000 00000000   501        0 6183 1
ffff8100614e2a00 49 3 0 4 2 15: 0200A8C0:807C 7A1226BD:03E3 01
0000007C:00000000 01:00000089 00000003   501        0 24919 2
ffff81007ea2b600 183 0 0 2 2 16: 0200A8C0:8C07 7DA355D1:1467 01
00000000:00000000 00:00000000 00000000   501        0 6186 1
ffff8100614e3c00 41 3 26 4 -1 17: 0100007F:0077 0100007F:BED7 01
00000000:00000000 00:00000000 00000000     0        0 21883 1
ffff8100614e1800 21 3 1 6 -1 18: 0200A8C0:852D 7A1226BD:0016 01
00000000:00000000 02:0000E189 00000000   501        0 5975 2
ffff81007ea2ce00 23 3 10 2 2 19: 0100007F:B4C6 0100007F:0DA5 01
00000000:00000000 00:00000000 00000000   501        0 3815 1
ffff81007ea2a400 20 3 18 5 -1 20: 0200A8C0:EBFC B81B2ECF:0747 01
00000000:00000000 00:00000000 00000000   501        0 11878 1
ffff81004900c800 74 3 0 4 3 21: 0100007F:0DA5 0100007F:B4C5 01
00000000:00000000 00:00000000 00000000     0        0 2930 1
ffff81007ea28c00 20 3 31 3 -1 22: 0100007F:BED7 0100007F:0077 01
00000000:00000000 00:00000000 00000000   501        0 21881 1
ffff8100614e3000 20 3 0 5 -1 23: 0200A8C0:839B 141B2ECF:0747 01
00000000:00000000 00:00000000 00000000   501        0 6331 1
ffff8100614e0c00 83 3 0 4 3 24: 0100007F:0DA5 0100007F:B4C6 01
00000000:00000000 00:00000000 00000000     0        0 3816 1
ffff81007ea2aa00 21 3 23 5 -1 25: 0100007F:B4C5 0100007F:0DA5 01
00000000:00000000 00:00000000 00000000 65534        0 2929 1
ffff81007ea28600 20 3 30 3 -1 26: 0200A8C0:DBE6 63C155D1:0050 01
00000000:00000000 00:00000000 00000000   501        0 23988 1
ffff81007e922400 21 3 8 4 -1 27: 0200A8C0:8CDA 26E43641:0747 01
00000000:00000000 00:00000000 00000000   501        0 21604 1
ffff8100614e6000 60 3 0 4 -1 28: 0200A8C0:C2F5 8D1A2ECF:0747 01
00000000:00000000 00:00000000 00000000   501        0 6328 1
ffff81007e924200 110 3 0 4 3 29: 0200A8C0:8806 2D6C2ECF:0747 01
00000000:00000000 00:00000000 00000000   501        0 17566 1
ffff81004900ce00 46 3 30 4 -1 30: 0200A8C0:96FF 27F9F03F:0050 01
00000000:00000000 00:00000000 00000000   501        0 23953 1
ffff81007ea2c800 55 3 8 3 -1 31: 0200A8C0:8078 7A1226BD:03E3 04
0000007D:00000000 01:000009BD 00000006     0        0 0 2
ffff81007ea2c200 6718 3 6 2 2                        =20

	And I can't use host and port at the same time with tcpdump (or
I did something wrong) so I used (I need to update this, can't find
the manpage... I tried to download a newer version but the link form
the site seems broken):

sudo tcpdump -w dump-mail.log -i eth0 port 995

	to capture mail traffic that was stuck (usually it only happens
with mail or nntp, interesting no?). All the other services (http,
ssh, ftp always work fine).

http://www.abusar.org/dump-mail.log

	But the file is small. I don't know if it will help.

	If not, no problem, just tell me and I'll try harder next time.
Thanks.

--=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
