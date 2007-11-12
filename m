From: "Antoine Zen-Ruffinen" <antoine.zen@gmail.com>
Subject: Problem with frame time stamping
Date: Mon, 12 Nov 2007 16:42:34 +0100
Message-ID: <2cbbd8de0711120742h35f27441p5f096e5e99e1d7dc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: patrik.arlos@bth.se
To: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear all,

I'm writing a network analyzer software using Linux and I need a VERY
precise frame time stamping. Therefor I am planing to add my own time
stamping algorithm on a modified network driver. For test purpose I
did so :

	skb->tstamp.tv64 = 0x00010002;
	netif_rx(skb);

On the user side, I ask for the timestamp that way :

	...
	sock = socket(AF_PACKET, SOCK_RAW, type);
	...
	//bind this socket with the interface using my modified driver.
	...
	recvByteCount = recv(sock, buffer, 1514, 0);
    	ioctl(sock, SIOCGSTAMP, &timeStamp);

I was surprised to see that the var timeStamp was still holding a
count of second since  year 1970.

Investigating a bit into the kernel code, I found that ioctl(sock,
SIOCGSTAMP, ...) was giving just the current kernel time using
ktime_get_real().

Are my investigation wrong ?
Is that a bug in kernel code ?
Is there an other way to access skb.tstamp from user side ?

Thank's to any one that can help me !

Antoine Zen-Ruffinen
