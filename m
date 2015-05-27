From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: tcp_tso_autosize() minimum is one packet
Date: Tue, 26 May 2015 17:36:34 -0700
Message-ID: <1432686994.4060.312.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150527000342.GA16379@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ncardwell@google.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38436 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492AbbE0Agh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 20:36:37 -0400
Received: by igcau1 with SMTP id au1so2245676igc.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 17:36:36 -0700 (PDT)
In-Reply-To: <20150527000342.GA16379@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-05-27 at 08:03 +0800, Herbert Xu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> > -               if (tso_segs == 1 || !max_segs) {
> > +               if (tso_segs == 1) {
> 
> What we're testing for here with max_segs is actually the question
> "is TSO enabled".  So with your patch we will be taking the TSO
> code path even when TSO is disabled.  Now this may or may not
> trigger the original bug that I was trying to fix but it still
> feels unsafe.
> 
> So please convince me that it is totally safe to take the TSO
> code path with TSO disabled, e.g., when PMTU causes tso_segs
> to be greater than one.

tldr:  "TSO with max_segs==1"  <is the same than> "no TSO/GSO"


So worth thing that will happen is that the call to
tcp_mss_split_point() / tso_fragment() will nicely split the (TSO/GSO)
packet in a nice non GSO packet of one MSS before transmit.

Right now, one can "ethtool -K eth0 tso off gso off" in the middle of a
TCP session and  tcp_write_xmit() automatically falls back to splitting
too big skbs that were cooked at the time GSO/TSO was considered true in
sendmsg().
  
Not sure what you need to be convinced ;)

Thanks !
