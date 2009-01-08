From: Speedster <speedster@haveacry.com>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Fri, 09 Jan 2009 00:04:42 +0900
Message-ID: <4966160A.20001@haveacry.com>
References: <bug-12327-10286@http.bugzilla.kernel.org/> <20081229214101.4c4f5ac1.akpm@linux-foundation.org> <Pine.LNX.4.64.0812311241490.3120@wrl-59.cs.helsinki.fi> <495BFEAF.6000006@haveacry.com> <20090102083402.GA24383@gondor.apana.org.au> <4961ECD2.1000502@haveacry.com> <20090107041732.GA22041@gondor.apana.org.au> <4964B303.4020708@haveacry.com> <20090108030745.GA1204@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010400030506050007090503"
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	bugme-daemon@bugzilla.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosted05.westnet.com.au ([203.10.1.219]:59857 "EHLO
	hosted05.westnet.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbZAHPEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 10:04:51 -0500
In-Reply-To: <20090108030745.GA1204@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010400030506050007090503
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Herbert Xu wrote:
> 
> Can you please take a look at /proc/net/snmp on the host and the
> guest to see if IP InDiscards is non-zero?

Both are 0

> Also now that we know the problem is definitely in the host/guest
> please take another set of dumps on the interfaces leading to and
> within the guest to see exactly which path of the system is dropping
> the reply.

Attached (all are the exact same attempted connection), and reveal some 
interesting information.

The path the inbound traffic should take is
1. vlan50 (host)
2. tap interface vnet3 (host) / eth0 (guest)
3. ppp0 (guest)

It looks as though when it is sent out the tap interface the payload 
length is incorrect in the PPPoE section of the frame. When it arrives 
via vlan50 it appears fine. Or at least that's what wireshark highlights 
for me :)

Dean

--------------010400030506050007090503
Content-Type: application/octet-stream;
 name="whimper-vlan50.cap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="whimper-vlan50.cap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAACBJmSXf1DgBSAAAAUgAAAAAYGFQZVAAWPiT3oYhk
EQBMBwA+ACFFEAA8VGNAAEAGy33KSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAXxAAAAgQFrAQC
CAr//7GhAAAAAAEDAwQJEmZJCsADAEQAAABEAAAAABY+JPehABgYVBlUiGQRAEwHADAAIUUA
ACzH0wAA6QbvLBGVnArKSKLjAFCBO2/q2cfl2+XDYBIf/sZ3AAACBAWsAAALEmZJtdQOAFIA
AABSAAAAABgYVBlUABY+JPehiGQRAEwHAD4AIUUQADxUZEAAQAbLfMpIouMRlZwKgTsAUOXb
5cIAAAAAoAIWsBaYAAACBAWsBAIICv//ss0AAAAAAQMDBAwSZklbeAMARAAAAEQAAAAAFj4k
96EAGBhUGVSIZBEATAcAMAAhRQAALODUAADpBtYrEZWcCspIouMAUIE7b+rZx+Xb5cNgEh/+
xncAAAIEBawAABESZkkV1Q4AUgAAAFIAAAAAGBhUGVQAFj4k96GIZBEATAcAPgAhRRAAPFRl
QABABst7ykii4xGVnAqBOwBQ5dvlwgAAAACgAhawFEAAAAIEBawEAggK//+1JQAAAAABAwME
EhJmSUh6AwBEAAAARAAAAAAWPiT3oQAYGFQZVIhkEQBMBwAwACFFAAAsLAUAAOkGivsRlZwK
ykii4wBQgTtv6tnH5dvlw2ASH/7GdwAAAgQFrAAAHRJmScDVDgBSAAAAUgAAAAAYGFQZVAAW
PiT3oYhkEQBMBwA+ACFFEAA8VGZAAEAGy3rKSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAPkAAA
AgQFrAQCCAr//7nVAAAAAAEDAwQeEmZJYXgDAEQAAABEAAAAABY+JPehABgYVBlUiGQRAEwH
ADAAIUUAACySlwAA6QYkaRGVnArKSKLjAFCBOzoF7r/l2+XDYBIf/udkAAACBAWsAAA=
--------------010400030506050007090503
Content-Type: application/octet-stream;
 name="whimper-vnet3.cap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="whimper-vnet3.cap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAACBJmSW31DgBSAAAAUgAAAAAYGFQZVAAWPiT3oYhk
EQBMBwA+ACFFEAA8VGNAAEAGy33KSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAXxAAAAgQFrAQC
CAr//7GhAAAAAAEDAwQJEmZJGMADAEIAAABCAAAAABY+JPehABgYVBlUiGQRAEwHADAAIUUA
ACzH0wAA6QbvLBGVnArKSKLjAFCBO2/q2cfl2+XDYBIf/sZ3AAACBAWsCxJmSaLUDgBSAAAA
UgAAAAAYGFQZVAAWPiT3oYhkEQBMBwA+ACFFEAA8VGRAAEAGy3zKSKLjEZWcCoE7AFDl2+XC
AAAAAKACFrAWmAAAAgQFrAQCCAr//7LNAAAAAAEDAwQMEmZJaXgDAEIAAABCAAAAABY+JPeh
ABgYVBlUiGQRAEwHADAAIUUAACzg1AAA6QbWKxGVnArKSKLjAFCBO2/q2cfl2+XDYBIf/sZ3
AAACBAWsERJmSQLVDgBSAAAAUgAAAAAYGFQZVAAWPiT3oYhkEQBMBwA+ACFFEAA8VGVAAEAG
y3vKSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAUQAAAAgQFrAQCCAr//7UlAAAAAAEDAwQSEmZJ
U3oDAEIAAABCAAAAABY+JPehABgYVBlUiGQRAEwHADAAIUUAACwsBQAA6QaK+xGVnArKSKLj
AFCBO2/q2cfl2+XDYBIf/sZ3AAACBAWsHRJmSbXVDgBSAAAAUgAAAAAYGFQZVAAWPiT3oYhk
EQBMBwA+ACFFEAA8VGZAAEAGy3rKSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAPkAAAAgQFrAQC
CAr//7nVAAAAAAEDAwQeEmZJb3gDAEIAAABCAAAAABY+JPehABgYVBlUiGQRAEwHADAAIUUA
ACySlwAA6QYkaRGVnArKSKLjAFCBOzoF7r/l2+XDYBIf/udkAAACBAWs
--------------010400030506050007090503
Content-Type: application/octet-stream;
 name="whinge-eth0.cap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="whinge-eth0.cap"

1MOyoQIABAAAAAAAAAAAAP//AAABAAAACBJmSVHwDgBSAAAAUgAAAAAYGFQZVAAWPiT3oYhk
EQBMBwA+ACFFEAA8VGNAAEAGy33KSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAXxAAAAgQFrAQC
CAr//7GhAAAAAAEDAwQJEmZJMLwDAEIAAABCAAAAABY+JPehABgYVBlUiGQRAEwHADAAIUUA
ACzH0wAA6QbvLBGVnArKSKLjAFCBO2/q2cfl2+XDYBIf/sZ3AAACBAWsCxJmSfLODgBSAAAA
UgAAAAAYGFQZVAAWPiT3oYhkEQBMBwA+ACFFEAA8VGRAAEAGy3zKSKLjEZWcCoE7AFDl2+XC
AAAAAKACFrAWmAAAAgQFrAQCCAr//7LNAAAAAAEDAwQMEmZJWHQDAEIAAABCAAAAABY+JPeh
ABgYVBlUiGQRAEwHADAAIUUAACzg1AAA6QbWKxGVnArKSKLjAFCBO2/q2cfl2+XDYBIf/sZ3
AAACBAWsERJmSerODgBSAAAAUgAAAAAYGFQZVAAWPiT3oYhkEQBMBwA+ACFFEAA8VGVAAEAG
y3vKSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAUQAAAAgQFrAQCCAr//7UlAAAAAAEDAwQSEmZJ
0HUDAEIAAABCAAAAABY+JPehABgYVBlUiGQRAEwHADAAIUUAACwsBQAA6QaK+xGVnArKSKLj
AFCBO2/q2cfl2+XDYBIf/sZ3AAACBAWsHRJmSeTODgBSAAAAUgAAAAAYGFQZVAAWPiT3oYhk
EQBMBwA+ACFFEAA8VGZAAEAGy3rKSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAPkAAAAgQFrAQC
CAr//7nVAAAAAAEDAwQeEmZJHXMDAEIAAABCAAAAABY+JPehABgYVBlUiGQRAEwHADAAIUUA
ACySlwAA6QYkaRGVnArKSKLjAFCBOzoF7r/l2+XDYBIf/udkAAACBAWs
--------------010400030506050007090503
Content-Type: application/octet-stream;
 name="whinge-ppp0.cap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="whinge-ppp0.cap"

1MOyoQIABAAAAAAAAAAAAP//AABxAAAACBJmSUXwDgBMAAAATAAAAAAEAgAAAAAAAAAAAAAA
CABFEAA8VGNAAEAGy33KSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAXxAAAAgQFrAQCCAr//7Gh
AAAAAAEDAwQLEmZJ4M4OAEwAAABMAAAAAAQCAAAAAAAAAAAAAAAIAEUQADxUZEAAQAbLfMpI
ouMRlZwKgTsAUOXb5cIAAAAAoAIWsBaYAAACBAWsBAIICv//ss0AAAAAAQMDBBESZknXzg4A
TAAAAEwAAAAABAIAAAAAAAAAAAAAAAgARRAAPFRlQABABst7ykii4xGVnAqBOwBQ5dvlwgAA
AACgAhawFEAAAAIEBawEAggK//+1JQAAAAABAwMEHRJmSdfODgBMAAAATAAAAAAEAgAAAAAA
AAAAAAAACABFEAA8VGZAAEAGy3rKSKLjEZWcCoE7AFDl2+XCAAAAAKACFrAPkAAAAgQFrAQC
CAr//7nVAAAAAAEDAwQ=
--------------010400030506050007090503--
