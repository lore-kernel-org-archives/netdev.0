From: "John Ye" <johny@asimco.com.cn>
Subject: RE: [PATCH 2.6.27.7-9-pae #7 SMP 1/1] networking tcp: Writing tcp socket be atomic
Date: Thu, 4 Feb 2010 10:03:44 +0800
Message-ID: <DB4F116661E3B0428456BB7E379EF4BB3C5F57@MX.asimcotech.com>
References: <474C17045AA24E3F8519EE76BAB47439@JOHNYE1> <20100203.085249.98326242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <kuznet@ms2.inr.ac.ru>, <netdev@vger.kernel.org>,
	<jmorris@namei.org>, <kaber@coreworks.de>,
	<linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

Thanks.
The option TCP_ATOMIC is not a must.
We can make atomic be default if the data size is less than a fixed siz=
e, just the same as pipe.
=46or example, if the data size is less than 512, we don't split the da=
ta so it goes atomically.

John Ye


-----Original Message-----
=46rom: David Miller [mailto:davem@davemloft.net]=20
Sent: 2010=C4=EA2=D4=C24=C8=D5 0:53
To: John Ye
Cc: kuznet@ms2.inr.ac.ru; netdev@vger.kernel.org; jmorris@namei.org; ka=
ber@coreworks.de; linux-kernel@vger.kernel.org
Subject: Re: [PATCH 2.6.27.7-9-pae #7 SMP 1/1] networking tcp: Writing =
tcp socket be atomic


Locking belongs inside of the application, not in the kernel.

As evidenced by the fact that you had to add new socket options, the
application needs to be modified anyways.

It's therefore just as easy to add the appropriate locking to the
sequences where the application writes over the TCP socket.  And
it avoids having to modify the kernel at all.
