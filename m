From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 05 Jul 2012 12:41:59 +0200
Message-ID: <1341484919.2583.3688.camel@edumazet-glaptop>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	 <1341474192.2583.3299.camel@edumazet-glaptop>
	 <CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	 <1341477192.2583.3415.camel@edumazet-glaptop>
	 <CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	 <1341481760.2583.3579.camel@edumazet-glaptop>
	 <CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:33866 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755430Ab2GEKmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 06:42:05 -0400
Received: by eaak11 with SMTP id k11so3175990eaa.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 03:42:03 -0700 (PDT)
In-Reply-To: <CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-05 at 18:32 +0800, Ming Lei wrote:

> After testing on beagle-xm, the patch is good and network is OK, but
> iperf performance is still no improvement, see below:
> 
> [root@root]#iperf -c 192.168.0.103 -w 131072 -t 10
> ------------------------------------------------------------
> Client connecting to 192.168.0.103, TCP port 5001
> TCP window size:   256 KByte (WARNING: requested   128 KByte)
> ------------------------------------------------------------
> [  3] local 192.168.0.119 port 46776 connected with 192.168.0.103 port 5001
> [ ID] Interval       Transfer     Bandwidth
> [  3]  0.0-10.0 sec  41.4 MBytes  34.7 Mbits/sec
> 

I fear there are copies in the tx path as well, in smsc95xx_tx_fixup()

Could you add traces in this function to check if skb_copy_expand() is
called ?
