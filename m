From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: avoid multiple ssthresh reductions in on
 retransmit window
Date: Wed, 18 Jun 2014 00:17:32 -0700
Message-ID: <1403075852.4559.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAK6E8=dwh1btNzX80YNre9u7rS+SgochXxHxDhQYQZCvY8yVMQ@mail.gmail.com>
	 <20140616211954.6E12BA3A89@unicorn.suse.cz>
	 <CAK6E8=dxszKmHssR7ib7Fxfm6hQRdbwBG1ygRvOXoSAXddBSPA@mail.gmail.com>
	 <CADVnQy=sd2V2A5Rzd+OtcH1a+un3-fATSn_acKdMKUcdbpGadg@mail.gmail.com>
	 <CAK6E8=fb0x5Z0dnA6PDbxJKYn3z1y42Pr555t7apLbT97R8O-Q@mail.gmail.com>
	 <CADVnQykk0pmryWdRjq21OXYK3Pvi5xWCkaB7Jf2acF5qtnzANg@mail.gmail.com>
	 <20140617122038.GA7275@unicorn.suse.cz>
	 <CAK6E8=e=EoxMfGMFnO90MVfBWGmoua8=4ptG978-jfD2S-J8Fw@mail.gmail.com>
	 <20140617224241.GA17969@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:59730 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751798AbaFRHRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 03:17:38 -0400
Received: by mail-wg0-f47.google.com with SMTP id k14so369341wgh.30
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2014 00:17:36 -0700 (PDT)
In-Reply-To: <20140617224241.GA17969@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-18 at 00:42 +0200, Michal Kubecek wrote:

> BtW, this is exactly the problem our customer is facing: they have
> relatively fast line (15 Mb/s) but with big buffers so that the
> roundtrip times can rise from unloaded 35 ms up to something like 1.5 s
> under full load.

It looks like some cwnd limiting would be nice ;)

BDP is about 45 packets for a 35ms rtt and 15 Mb/s link.

> 
> What happens is this: cwnd initally rises to ~2100 then first drops
> are encountered, cwnd is set to 1 and ssthresh to ~1050. The slow start
> lets cwnd reach ssthresh but after that, a slow linear growth follows.
> In this state, all in-flight packets are dropped (simulation of what
> happens on router switchover) so that cwnd is reset to 1 again and
> ssthresh to something like 530-550 (cwnd was a bit higher than ssthresh).
> If a packet loss comes shortly after that, cwnd is still very low and
> ssthresh is reduced to half of that cwnd (i.e. much lower than to half
> of ssthresh). If unlucky, one can even end up with ssthresh reduced to 2
> which takes really long to recover from.
