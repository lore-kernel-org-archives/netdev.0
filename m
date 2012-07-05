From: Ming Lei <tom.leiming@gmail.com>
Subject: Re: TCP transmit performance regression
Date: Thu, 5 Jul 2012 22:01:13 +0800
Message-ID: <CACVXFVPksMd8CGZWEGBXBXB5NZCg3QOZreOLavkV-Z2pjE-M_A@mail.gmail.com>
References: <CACVXFVNM-Db=_793SVfRj+nxGtNG0pRFrwc_F9TGbU0FfES63A@mail.gmail.com>
	<1341474192.2583.3299.camel@edumazet-glaptop>
	<CACVXFVNxcdEYd-KmkUe9=8+x_9s-ZVuoM=FfZ=QXa7w_qRiTnw@mail.gmail.com>
	<1341477192.2583.3415.camel@edumazet-glaptop>
	<CACVXFVPTXB7t=zwkm+HTgDaF3bA02bzff_52S+UAr51PfpvpCg@mail.gmail.com>
	<1341481760.2583.3579.camel@edumazet-glaptop>
	<CACVXFVNZ=64+=w1ZapXeXq7oYz0OBbBRLuH8rNSeDHyz7zGOZw@mail.gmail.com>
	<1341484919.2583.3688.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Network Development <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:43248 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751694Ab2GEOBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2012 10:01:14 -0400
Received: by obbuo13 with SMTP id uo13so13073225obb.19
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2012 07:01:13 -0700 (PDT)
In-Reply-To: <1341484919.2583.3688.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 5, 2012 at 6:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-07-05 at 18:32 +0800, Ming Lei wrote:
>
>> After testing on beagle-xm, the patch is good and network is OK, but
>> iperf performance is still no improvement, see below:
>>
>> [root@root]#iperf -c 192.168.0.103 -w 131072 -t 10
>> ------------------------------------------------------------
>> Client connecting to 192.168.0.103, TCP port 5001
>> TCP window size:   256 KByte (WARNING: requested   128 KByte)
>> ------------------------------------------------------------
>> [  3] local 192.168.0.119 port 46776 connected with 192.168.0.103 port 5001
>> [ ID] Interval       Transfer     Bandwidth
>> [  3]  0.0-10.0 sec  41.4 MBytes  34.7 Mbits/sec
>>
>
> I fear there are copies in the tx path as well, in smsc95xx_tx_fixup()

Basically, copy path will be bypassed since hard_header_len
has included the 'overhead' already.

> (SLAB debug is going to cost a lot with big bufers)

At default SMSC95xx turbo mode is true, rx buffer will be very big
(17.5K). Or the large rx buffer size puts limit on concurrent URBs/SKBs
count.  Both two may cause the problem.

Thanks,
-- 
Ming Lei
