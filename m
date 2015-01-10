From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Query regarding sk_filter
Date: Fri, 9 Jan 2015 16:51:46 -0800
Message-ID: <CAADnVQKNF43g4RdMTRbPJ2m_XYwyekpmHb93UyarWJB-z8iGAQ@mail.gmail.com>
References: <20150109112302.GA9428@kumar-pc.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kumar Sanghvi <kumaras@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f54.google.com ([209.85.216.54]:44366 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758077AbbAJAwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 19:52:07 -0500
Received: by mail-qa0-f54.google.com with SMTP id i13so9360440qae.13
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 16:52:06 -0800 (PST)
In-Reply-To: <20150109112302.GA9428@kumar-pc.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 9, 2015 at 3:23 AM, Kumar Sanghvi <kumaras@chelsio.com> wrote:
> Hi netdev team,
>
> I have a query regarding sk_filter call in tcp receive path:
>
> In 'tcp_v4_rcv' function, if sk is found by __inet_lookup_skb then,
> down the line, there is a call to sk_filter to ensure if the incoming packet
> is allowed to be processed for that sk.
>
> However, in 'tcp_v4_hnd_req' function, if nsk is found by inet_lookup_established
> then, later, there does not seem to be a sk_filter call for that nsk in the receive
> path processing.
>
> I am wondering shouldn't there be a sk_filter call on nsk found in 'tcp_v4_hnd_req'
> function ? Or, probably I am missing something.

hmm. I'm not sure what you're seeing.
tcp_v4_hnd_req() is called from tcp_v4_do_rcv() which is called
after sk_filter() check is done in tcp_v4_rcv() (either directly
or via prequeue/backlog)

> I am running some high rate syn-flood tests and trying to understand
> the sk_filter behaviour in this case.

are you saying not all of syn packets are reaching filter?
