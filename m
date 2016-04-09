From: Jesse Gross <jesse@kernel.org>
Subject: Re: [RFC PATCH 07/11] GENEVE: Add option to mangle IP IDs on inner
 headers when using TSO
Date: Sat, 9 Apr 2016 12:52:46 -0300
Message-ID: <CAEh+42j5_SKku5EWexLi+1Ch4Eu=SoijMGSCYyZAd39GeMq8GQ@mail.gmail.com>
References: <20160407222211.11142.41024.stgit@ahduyck-xeon-server>
 <20160407223237.11142.33072.stgit@ahduyck-xeon-server> <CAEh+42jyh0EWwaOAu3KNSQKEv3NRgjPT_4QRYUmLRSXtsMgWJw@mail.gmail.com>
 <CAKgT0Ufc8EiqCR5opSFUCE2v3hFCmnS641o+epyi+G92bD+yww@mail.gmail.com>
 <CAEh+42gjqeGK94xvVQFuiUF=c3YKY2SCWOL=y=2gBsHyUxQ+GA@mail.gmail.com> <CAKgT0UcehJaKhEQCATuyp48Q0gqofk7JjwsakNo1KgJd2YH-TA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexander Duyck <aduyck@mirantis.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <edumazet@google.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:57797 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754027AbcDIPxF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2016 11:53:05 -0400
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 62F0D202BE
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 15:53:03 +0000 (UTC)
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 20F4E2026D
	for <netdev@vger.kernel.org>; Sat,  9 Apr 2016 15:53:02 +0000 (UTC)
Received: by mail-qg0-f46.google.com with SMTP id j35so113531886qge.0
        for <netdev@vger.kernel.org>; Sat, 09 Apr 2016 08:53:02 -0700 (PDT)
In-Reply-To: <CAKgT0UcehJaKhEQCATuyp48Q0gqofk7JjwsakNo1KgJd2YH-TA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 8, 2016 at 7:04 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Fri, Apr 8, 2016 at 2:40 PM, Jesse Gross <jesse@kernel.org> wrote:
>> Maybe I missed it but I didn't see any checks for the DF bit being set
>> when we transmit a packet with NETIF_F_TSO_MANGLEID. Even if I am
>> comfortable mangling my IDs in the DF case, I don't think this would
>> ever extend to non-DF packets. In the documentation you noted that it
>> is the driver's responsibility to do this check but I couldn't find it
>> in either ixgbe or igb. It would also be nice if the core stack could
>> enforce it somehow as well rather than each driver.
>
> Yeah I had glossed over that in the igb and ixgbe patches.  A check is
> only really needed for the incrementing to non-incrementing case and I
> wasn't sure how common it was to have TCP with an IP header that
> didn't set the DF bit.  In the case of the outer headers igb and ixgbe
> will increment the IP ID always so we don't have to worry about if DF
> is set of not there.  For the inner headers I had fudged it a bit and
> didn't add the validation.  If needed I can see about adding that
> shortly.

TCP without the DF bit set is not the default but it is possible (it
can be enabled by setting /proc/sys/net/ipv4/ip_no_pmtu_disc). I also
did a quick check of some Internet services and at least some of them
seem to return TCP without DF, so it's not too rare.
