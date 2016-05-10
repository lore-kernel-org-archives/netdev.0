From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] fq_codel: add memory limitation per queue
Date: Mon, 09 May 2016 22:10:36 -0700
Message-ID: <1462857036.23934.58.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
	 <865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com>
	 <1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
	 <C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com>
	 <1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
	 <1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
	 <1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
	 <1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
	 <1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAA93jw4XZ1+LLX1z6wQ6DHsp4vFCS5zmMz-uku_8SBNG_KuUxA@mail.gmail.com>
	 <542135C7-D7CC-4E33-B35B-C2AD259FA5AB@gmx.de>
	 <20160506133323.0b190f47@redhat.com>
	 <D29AB9B2-D514-4D14-9A16-CFB9ECD05B17@gmx.de>
	 <1462541156.13075.34.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462550112.13075.47.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpUfJxMxQXia8JOH5xouSFMThrdZWZMUuQ0q=bSmp8oEEQ@mail.gmail.com>
	 <1462768295.23934.28.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpXOTjdY4AsQVV6qz_U7be6m6OnYO0ZNSanxo6pXqdOu+Q@mail.gmail.com>
	 <1462804008.23934.30.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpURNs3vVVN1cceRLh2ptvsMno3bPubc9wwfQvcWe8je8g@mail.gmail.com>
	 <1462855514.23934.51.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAM_iQpUusrr7W9diudUad+iDg3s5-4We6Z7tVzjLfMSVVJ+MMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Dave =?ISO-8859-1?Q?T=E4ht?= <dave.taht@gmail.com>,
	netdev <netdev@vger.kernel.org>, moeller0 <moeller0@gmx.de>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34137 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348AbcEJFKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 01:10:40 -0400
Received: by mail-pf0-f172.google.com with SMTP id y69so1274031pfb.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 22:10:40 -0700 (PDT)
In-Reply-To: <CAM_iQpUusrr7W9diudUad+iDg3s5-4We6Z7tVzjLfMSVVJ+MMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-09 at 21:57 -0700, Cong Wang wrote:

> Sure, but we are talking about memory constraint case, aren't we?
> 
> If the whole system are suffering from memory pressure, the whole
> qdisc should be halted?

Please read the patch again.

I added a mem control, exactly to control memory usage in the first
place. If the admin allows this qdisc to consume 4MBytes, then we can
queue up to 4 Mbytes on it.

If we evict packets from _other_ flow because of whatever limit is hit
(being number of packets or memory usage), we do not report to the
innocent guy that some packets were dropped.

The innocent guy packet _is_ queued and _should_ be sent eventually.

Of course, if we could predict the future and that 456 usec later, the
packet will be lost anyway, we would notify the innocent guy right away.

But this is left for future improvement.
