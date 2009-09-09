From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Wed, 09 Sep 2009 17:09:06 +0200
Message-ID: <4AA7C512.6040100@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:34207 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbZIIPJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 11:09:37 -0400
In-Reply-To: <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Wed, 9 Sep 2009, Eric Dumazet wrote:
>=20
>> In order to reproduce this here, could you tell me if you use
>>
>> Producer linux-2.6.22 -> Receiver 2.6.22
>> Producer linux-2.6.31 -> Receiver 2.6.31
>=20
> I use the above setup.

Then frames are sent on wire but not received

(they are received via  mc loop, internal stack magic)


# ./mcast -L -n1 -r 10000
WARNING: Multiple active ethernet devices. Using local address 192.168.=
0.1
Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0 or=
igin 192.168.0.1
Sender: Sending 10000 msgs/ch/sec on 1 channels. Probe interval=3D0.001=
-1 sec.

TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us S=
tdDv
100000      0      0      0   10000  3000.0    7.84    8.89   10.51  0.=
66

# uname -a
Linux erd 2.6.30.5 #2 SMP Mon Sep 7 17:15:43 CEST 2009 i686 i686 i386 G=
NU/Linux



I tried an old kernel on same hardware :

# ./mcast -L -n1 -r 10000
WARNING: Multiple active ethernet devices. Using local address 55.225.1=
8.6
Receiver: Listening to control channel 239.0.192.1
Receiver: Subscribing to 1 MC addresses 239.0.192-254.2-254 offset 0 or=
igin 55.225.18.6
Sender: Sending 10000 msgs/ch/sec on 1 channels. Probe interval=3D0.001=
-1 sec.

TotalMsg   Lost SeqErr TXDrop Msg/Sec  KB/Sec  Min/us  Avg/us  Max/us S=
tdDv
   99999      0      0      0    9998     0.0    9.00    9.95   14.50  =
1.56

Linux erd 2.6.9-55.ELsmp #1 SMP Fri Apr 20 17:03:35 EDT 2007 i686 i686 =
i386 GNU/Linux

So my numbers seem much better than yours...
