From: Michal Vanco <vanco@satro.sk>
Subject: Re: e1000 packet corruption problem
Date: Tue, 29 Mar 2005 17:42:50 +0200
Message-ID: <4249777A.8080008@satro.sk>
References: <C925F8B43D79CC49ACD0601FB68FF50C03793405@orsmsx408>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig494A3F60D9B7DC71693122AB"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C03793405@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig494A3F60D9B7DC71693122AB
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Brandeburg, Jesse wrote:
>>I have 4-port Intel e1000 card in my dual Amd Opteron machine:
>>0000:02:04.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>>Controller (rev 02)
>>0000:02:05.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>>Controller (rev 02)
>>0000:02:06.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>>Controller (rev 02)
>>0000:02:07.0 Ethernet controller: Intel Corp. 82540EM Gigabit Ethernet
>>Controller (rev 02)
>>
>>with this driver:
>>Intel(R) PRO/1000 Network Driver - version 5.7.6
>>Copyright (c) 1999-2004 Intel Corporation.
>
>
> Standard questions: what kernel version, what exact machine (and bios),
> lspci -n will help here.

Ooops. Sorry. It's 2.6.12-rc1 but the same behaviour on 2.6.10 and 2.6.11.

# cat /proc/cpuinfo | egrep 'proc|model name'
processor       : 0
model name      : AMD Opteron(tm) Processor 246
processor       : 1
model name      : AMD Opteron(tm) Processor 246

# lspci -n
0000:00:06.0 0604: 1022:7460 (rev 07)
0000:00:07.0 0601: 1022:7468 (rev 05)
0000:00:07.1 0101: 1022:7469 (rev 03)
0000:00:07.2 0c05: 1022:746a (rev 02)
0000:00:07.3 0680: 1022:746b (rev 05)
0000:00:0a.0 0604: 1022:7450 (rev 12)
0000:00:0a.1 0800: 1022:7451 (rev 01)
0000:00:0b.0 0604: 1022:7450 (rev 12)
0000:00:0b.1 0800: 1022:7451 (rev 01)
0000:00:18.0 0600: 1022:1100
0000:00:18.1 0600: 1022:1101
0000:00:18.2 0600: 1022:1102
0000:00:18.3 0600: 1022:1103
0000:00:19.0 0600: 1022:1100
0000:00:19.1 0600: 1022:1101
0000:00:19.2 0600: 1022:1102
0000:00:19.3 0600: 1022:1103
0000:01:03.0 0604: 12d8:8154 (rev 01)
0000:02:04.0 0200: 8086:100e (rev 02)
0000:02:05.0 0200: 8086:100e (rev 02)
0000:02:06.0 0200: 8086:100e (rev 02)
0000:02:07.0 0200: 8086:100e (rev 02)
0000:03:06.0 0100: 9005:801d (rev 10)
0000:03:06.1 0100: 9005:801d (rev 10)
0000:03:09.0 0200: 14e4:1648 (rev 03)
0000:03:09.1 0200: 14e4:1648 (rev 03)
0000:04:00.0 0c03: 1022:7464 (rev 0b)
0000:04:00.1 0c03: 1022:7464 (rev 0b)
0000:04:05.0 0180: 1095:3114 (rev 02)
0000:04:06.0 0300: 1002:4752 (rev 27)
0000:04:08.0 0200: 8086:1229 (rev 10)

>
> You might be having interrupt routing problems, have you tried
> pci=noapic as a boot parameter?
>
> The data corruption is puzzling.
>

I didn't but I'll tomorrow.

>
>>eth3 is autonegotiated at 100 Mbps FDX.
>>
>>Trying to forward packets through eth3 causes corruption of packets.
>>I've got 'Corrupted MAC on input' trying to download (or copy) something
>>using scp. Using ftp doesn't emit any error, but all files downloaded
>>are apparently corrupted.
>>
>>After that I've tried to disable all off-loading. In this case no error
>>is visible but all download stalls forever.
>
>
> How did you disable all offloading? With ethtool? Did you disable TSO
> and TX/RX checksumming?  You left scatter gather on, right?
>

Well. Actually I did this:

# ethtool -K eth3 rx off tx off sg off tso off

>
>>Is this problem related only to e1000 driver or any GigE cards? Is
>
> there
>
>>any fix available?
>
>
> Can you try the card in another (non opteron) machine?  Does your
> opteron machine pci bus support PCI-X/133?
>

I did testing on Wi****s 2K3 and it worked perfectly on the same machine.

> If we can reproduce this we can likely get a fix, but without a
> reproduction its unlikely because we haven't seen problems like this
> around here.
>
> Jesse
>

regards,
michal

--------------enig494A3F60D9B7DC71693122AB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.0 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFCSXd9SBxxqpMaGkMRAnuaAKCC9q3KLq/gDEI1AvspOKsDCTJfrACgz+jJ
m0RrcA/Ayv2MxrC0MINZHos=
=Pkn5
-----END PGP SIGNATURE-----

--------------enig494A3F60D9B7DC71693122AB--
