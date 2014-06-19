From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Wed, 18 Jun 2014 19:28:57 -0700
Message-ID: <1403144937.1225.1.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
	 <20140616211954.6E12BA3A89@unicorn.suse.cz>
	 <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
	 <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
	 <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
	 <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com>
	 <20140617122038.GA7275@unicorn.suse.cz>
	 <CAK6E8=e=EoxMfGMFnO90MVfBWGmoua8=4ptG978-jfD2S-J8Fw@mail.gmail.com>
	 <20140617224241.GA17969@unicorn.suse.cz>
	 <2421.1403051930@localhost.localdomain>
	 <CADVnQy=qdaB7GEK8Ggenr92ckjwM3jOdsS18KEQver=9haWmCA@mail.gmail.com>
	 <11392.1403142743@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Yuchung Cheng <ycheng@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Jay Vosburgh <jay.vosburgh@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:48079 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756898AbaFSC3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 22:29:03 -0400
Received: by mail-wi0-f181.google.com with SMTP id n3so2076222wiv.8
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 19:29:01 -0700 (PDT)
In-Reply-To: <11392.1403142743@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-18 at 18:52 -0700, Jay Vosburgh wrote:
> 	The test involves adding 40 ms of delay in and out from machine
> A with netem, then running iperf from A to B.  Once the iperf reaches a
> steady cwnd, on B, I add an iptables rule to drop 1 packet out of every
> 1000 coming from A, then remove the rule after 10 seconds.  The behavior
> resulting from this closely matches what I see on the real systems.

Please share the netem setup. Are you sure you do not drop frames on
netem ? (considering you disable GSO/TSO netem has to be able to store a
lot of packets)
