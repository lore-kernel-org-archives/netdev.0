From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Query regarding sk_filter
Date: Mon, 12 Jan 2015 10:17:16 -0800
Message-ID: <CAADnVQJx+6Pv0qTSkKgnW8aqCwVtz4oDaVC6tR-Df6XFFrjMDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Kumar Sanghvi <kumaras@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f54.google.com ([209.85.192.54]:62199 "EHLO
	mail-qg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752542AbbALSRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 13:17:38 -0500
Received: by mail-qg0-f54.google.com with SMTP id l89so18873807qgf.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 10:17:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 10, 2015 at 4:40 AM, Kumar Sanghvi <kumaras@chelsio.com> wrote:
>
> May be, the question that I should have asked is : do child socket and parent listening socket have the
> same sk_filter applied i.e. do child socket inherit sk_filter from parent listening socket ?

yes. socket returned from accept() inherits filter from parent socket.
if you're curious the path is:
tcp_check_req - tcp_v4_syn_recv_sock - tcp_create_openreq_child - sk_clone_lock
