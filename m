From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: add BQL support
Date: Fri, 08 Apr 2016 11:23:20 -0700
Message-ID: <1460139800.6473.444.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1459903801-83727-1-git-send-email-pgynther@google.com>
	 <CAGVrzcbHGq7YP6kJ+M+jM+CCsKXMoqtzkf04YHPj+kseqm__9A@mail.gmail.com>
	 <CAGXr9JED3WLEQr67FrMJoJnUaYJwOcnwRE4JxHTaf+0ha00kig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, opendmb@gmail.com,
	Jaedon Shin <jaedon.shin@gmail.com>
To: Petri Gynther <pgynther@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33998 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbcDHSXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 14:23:23 -0400
Received: by mail-pf0-f181.google.com with SMTP id c20so80372440pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 11:23:22 -0700 (PDT)
In-Reply-To: <CAGXr9JED3WLEQr67FrMJoJnUaYJwOcnwRE4JxHTaf+0ha00kig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-08 at 09:54 -0700, Petri Gynther wrote:
> On Wed, Apr 6, 2016 at 1:25 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> >
> > 2016-04-05 17:50 GMT-07:00 Petri Gynther <pgynther@google.com>:
> > > Add Byte Queue Limits (BQL) support to bcmgenet driver.
> > >
> > > Signed-off-by: Petri Gynther <pgynther@google.com>
> >
> > Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> >
> > Thanks!
> > --
> > Florian
> 
> Any further comments?
> 
> Notable difference from some other drivers --
> netdev_tx_reset_queue(txq) is called for all queues in
> bcmgenet_netif_start(), just before netif_tx_start_all_queues(dev).
> This is to ensure that BQL is reset before the interface becomes
> operational.
> 
> I think that is the right place for these calls.
> 
> Some other drivers call it from the "interface down" path.

BQL is ready to go at device setup :

__QUEUE_STATE_STACK_XOFF is not set

dql_reset() was called from dql_init(), called from
netdev_init_one_queue()
