From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Tue, 26 May 2015 19:14:41 -0700
Message-ID: <1432692881.4060.333.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150527000342.GA16379@gondor.apana.org.au>
	 <1432686994.4060.312.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150527013840.GA20585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:33823 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518AbbE0COo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 22:14:44 -0400
Received: by ieczm2 with SMTP id zm2so3462130iec.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 19:14:43 -0700 (PDT)
In-Reply-To: <20150527013840.GA20585@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 09:38 +0800, Herbert Xu wrote:
> On Tue, May 26, 2015 at 05:36:34PM -0700, Eric Dumazet wrote:
> > 
> > tldr:  "TSO with max_segs==1"  <is the same than> "no TSO/GSO"
> 
> Not really.  They're not identical.  For example, before your
> patch a packet greater than MSS with TSO disabled would call
> tcp_nagle_test, with your patch it will call tcp_tso_should_defer
> instead.

Well, given that a device can set gso_max_segs to one, if there is a bug
here we'll need to fix it asap.

Fact that Nagle or tso should defer applies in this corner case is not
very important here, unless you have a specific case in mind ?
Anyway I double checked and I believes it is fine.

We normally deal with dynamic MSS changes, even for non GSO cases.

A non GSO packet temporarily becomes a GSO one in tcp_init_tso_segs()
(because its skb->len is bigger than cur_mss)

Then we split it.

Nagle or tso should defer would take same decision : send one full MSS.

By the time the last 'segment' (possibly smaller than mss) will be
considered, Nagle might apply there.

Thanks !
