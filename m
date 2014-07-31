From: Willem de Bruijn <willemb@google.com>
Subject: Re: [PATCH net-next v4 0/5] net-timestamp: additional sw tstamps and
Date: Thu, 31 Jul 2014 17:36:16 -0400
Message-ID: <CA+FuTSe1T4-CtK88rBrm_yymer5iEPR7f8p-+bYHSW_4zMpAUg@mail.gmail.com>
References: <1406735328-7520-1-git-send-email-willemb@google.com> <20140731.134330.1615160836103431950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:56815 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbaGaVgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 17:36:47 -0400
Received: by mail-qg0-f52.google.com with SMTP id f51so4604199qge.39
        for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 14:36:46 -0700 (PDT)
In-Reply-To: <20140731.134330.1615160836103431950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm mostly fine with this patchset, the only major blocker is the bit
> that changes TCP segmenting behavior when timestamps are enabled.  I
> really don't want to see us doing that, because that makes the
> timestamps non-passive.

Good point. It can be avoided with some storage overhead.

The only reason for locking the buffers is to ensure that
the tracked byte is the last byte in the packet. We have to
know the tracked byte at GSO time, to apply the SKBTX_..
flag to the right segment, and at ACK, to identify when the cumulative
ACK exceeds this byte for the first time.

An earlier internal version of the patch did not lock the buffers, but
recorded the seqno in skb_shared_info and referenced that in these
cases. The obvious drawback is having to store an u32 in
skb_shinfo. We did just regain 64b with the removal of syststamp,
though. Would this be a reasonable approach?

> Please work towards a solution to that problem and also fixup the
> minor naming et al. issues I brought up too.

The other issues are clear and easy to fix. Thanks for the review, David.
