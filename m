From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] macvlan: allow to enqueue broadcast pkt on virtual
 device
Date: Fri, 19 Sep 2014 14:35:01 -0700
Message-ID: <1411162501.26859.39.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410941288-1880-1-git-send-email-nicolas.dichtel@6wind.com>
	 <CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:37286 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757910AbaISVfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 17:35:04 -0400
Received: by mail-pa0-f51.google.com with SMTP id fa1so880031pad.10
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 14:35:03 -0700 (PDT)
In-Reply-To: <CAHA+R7OQ=R8Y0LDVormukRjdosODiRuGq+NTrZQ08sXvfJYUnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-09-19 at 14:24 -0700, Cong Wang wrote:
> On Wed, Sep 17, 2014 at 1:08 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
> > Since commit 412ca1550cbe ("macvlan: Move broadcasts into a work queue"), the
> > driver uses tx_queue_len of the master device as the limit of packets enqueuing.
> > Problem is that virtual drivers have this value set to 0, thus all broadcast
> > packets were rejected.
> > Because tx_queue_len was arbitrarily chosen, I replace it with a static limit
> > of 1000 (also arbitrarily chosen).
> >
> 
> Hmm, why not manually set this tx_queue_len to fix it?
> 
> At least fifo qdisc also uses tx_queue_len, and when you bond
> you have to set it to non-zero.


This is not true. We usually leave virtual devices with tx_queue_len to
0, otherwise you get a qdisc on them for nothing...

Only when you want to have say HTB on the bonding, you might need to
change tx_queue_len

> 
> I am not saying using this tx_queue_len is absolutely correct,
> I am saying it may be expected to set tx_queue_len by yourself.

I disagree.
