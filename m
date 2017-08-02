From: Mason <slash.tmp@free.fr>
Subject: Re: [RFC PATCH v2 0/2] nb8800 suspend/resume support
Date: Wed, 2 Aug 2017 22:02:24 +0200
Message-ID: <71dd7987-8c43-2548-5058-51a95658da71@free.fr>
References: <33d1ab47-6098-5e3f-8a3c-f72626d07113@free.fr>
 <aa8885b8-e6bb-3624-2bf9-0bb40505ac54@free.fr>
 <dd883398-1511-0bfd-972b-a11ef8709f0d@free.fr> <yw1xshhagexd.fsf@mansr.com>
 <9e8e12b1-74e2-8323-ec16-eebda46b2a3d@free.fr> <yw1xo9rygdyu.fsf@mansr.com>
 <6906dccf-bec9-0fc8-a34a-c39c05ada917@free.fr> <yw1xk22mgdcx.fsf@mansr.com>
 <f1554ee7-2151-1304-c5c1-35264b9be5be@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:43932 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751154AbdHBUCb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 16:02:31 -0400
In-Reply-To: <f1554ee7-2151-1304-c5c1-35264b9be5be@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/08/2017 19:31, Mason wrote:

> # iperf3 -c 172.27.64.45 -u -b 950M
> Connecting to host 172.27.64.45, port 5201
> [  4] local 172.27.64.1 port 55533 connected to 172.27.64.45 port 5201
> [ ID] Interval           Transfer     Bandwidth       Total Datagrams
> [  4]   0.00-1.00   sec   102 MBytes   858 Mbits/sec  13091  
> [  4]   1.00-2.00   sec   114 MBytes   953 Mbits/sec  14541  

114 MB in 14541 packets => 7840 bytes per packet
Is iperf3 sending jumbo frames??
In the nb8800 driver, RX_BUF_SIZE is only 1552,
how would it deal with jumbo frames... truncate?

> # iperf3 -c 172.27.64.45 -u -b 950M -l 800
> Connecting to host 172.27.64.45, port 5201
> [  4] local 172.27.64.1 port 35197 connected to 172.27.64.45 port 5201
> [ ID] Interval           Transfer     Bandwidth       Total Datagrams
> [  4]   0.00-1.00   sec  90.6 MBytes   760 Mbits/sec  118724  
> [  4]   1.00-2.00   sec   107 MBytes   894 Mbits/sec  139718  

107 MB in 139718 packets => 766 bytes per packet
800 - 8 (UDP) - 20 (IPv4) = 772 bytes per packet
I suppose that's close enough...
772 * 139718 = 107.86 MB

I need to run the test slightly slower, to prevent
packet loss at the sender.

Perhaps -b 0 or -b 800M

Regards.
