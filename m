From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Mon, 08 Oct 2012 11:47:20 +0200
Message-ID: <1349689640.21172.3008.camel@edumazet-glaptop>
References: <409ac8b30a6994028562e1a159ac60aa@justnet.pl>
	 <1349677373.21172.2756.camel@edumazet-glaptop>
	 <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: adam.niescierowicz@justnet.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:33849 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751144Ab2JHJrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 05:47:24 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so2110263lag.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 02:47:23 -0700 (PDT)
In-Reply-To: <9819d6943a7cfddfc8fa49217aa4842e@justnet.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-08 at 11:29 +0200, Nie=C5=9Bcierowicz Adam wrote:
> >
> > You should use RPS on eth2/eth3 because they are non multi queue.
> >
> > Documentation/networking/scaling.txt should give you all the needed=
=20
> > info
>=20
> I set processors for rps such as affinity, unfortunately it did not=20
> help
>=20
> ---
> cat /sys/class/net/eth{2,3,4,5}/queues/rx-0/rps_cpus
> 0040
> 0080
> 0100
> 0200
> ---
> CPU affinity http://wklej.org/id/843161/
>=20
>=20

I said eth2 and eth3

And you should use cpu11->cpu15 instead of cpu6->cpu9 since they are in
use...

Anyway you dont say where are drops, (ifconfig give us very few drops)

Also your eth0 seems to have a strange balance :

RX interrupts seems to be well balanced on 4 queues :

76:        503          0  169271690          0          0          0  =
        PCI-MSI-edge      eth0-rx-0
77:        405          0          0  164532538          0          0  =
        PCI-MSI-edge      eth0-rx-1
78:        408          0          0          0  152778723          0  =
        PCI-MSI-edge      eth0-rx-2
79:        349          0          0          0          0  155011301  =
        PCI-MSI-edge      eth0-rx-3
80:        144          0  443432394          0          0          0  =
        PCI-MSI-edge      eth0-tx-0
81:         18          0          0    2043311          0          0  =
        PCI-MSI-edge      eth0-tx-1
82:         30          0          0          0    1934537          0  =
        PCI-MSI-edge      eth0-tx-2
83:        137          0          0          0          0    1968272  =
        PCI-MSI-edge      eth0-tx-3

But TX seems to mostly use queue 0

Packets sent to eth0 are coming from where ?
