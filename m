From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: seeing strange values for tcp sk_rmem_alloc
Date: Tue, 01 Dec 2009 18:52:12 +0100
Message-ID: <4B1557CC.4060503@gmail.com>
References: <4B15416A.2060202@nortel.com> <4B154B29.1030807@cosmosbay.com> <4B155252.1040604@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754507AbZLARwM@vger.kernel.org>
In-Reply-To: <4B155252.1040604@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen a =E9crit :

> I realize this.  I sent the data from a socket to itself.  It could j=
ust
> as easily be done with two tcp sockets.  The important thing is that =
I
> control both the tx and rx sides, so I know how much data should be
> present in the rx queue at any point in time.
>=20
> The part that surprised me was that I could send multiple chunks of d=
ata
> without sk_rmem_alloc changing on the socket to which the data was be=
ing
> sent.  Then it would jump up by a large amount (up to 20K) all at onc=
e.
>=20
> I'm starting to suspect that the discrepency might have something to =
do
> with the skb_copy_datagram_iovec() call in tcp_data_queue(), and how
> skb_set_owner_r() is only called if "eaten" is <=3D 0.  This could be
> totally off-base though.
>=20

If you dont read() your socket, then skb_copy_datagram_iovec() is not c=
alled

But be careful of sender tcp stack : It might be delayed a bit,
because it waits for receiver to open its window (slow start)

You probably need something like

while (1) {
	send(fd1, buffer, 2Kbytes);
	sleep(2); // let tcp stack flush its write buffers
	display_sk_rmem_alloc(fd2);
}
