From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net-next v2 2/2] net: diag: allow socket bytecode filters
 to match socket marks
Date: Thu, 25 Aug 2016 00:03:02 +0900
Message-ID: <CAKD1Yr35Tvi03fpE14j0dk8DuhAWs6KRekd3DzOeq7Hf97CUJg@mail.gmail.com>
References: <1472021186-4106-1-git-send-email-lorenzo@google.com>
 <1472021186-4106-2-git-send-email-lorenzo@google.com> <77441548-8f56-08de-4b76-00ed404a6ffe@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>, Erik Kline <ek@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:38249 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756270AbcHXPDY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 11:03:24 -0400
Received: by mail-it0-f45.google.com with SMTP id n128so38520039ith.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 08:03:23 -0700 (PDT)
In-Reply-To: <77441548-8f56-08de-4b76-00ed404a6ffe@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 24, 2016 at 11:35 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> sock_diag_destroy already requires ADMIN for destroying sockets, so adding here just prevents listing them. Given that and the fact that the diag API does not pass the mark value is there a reason to add the extra ADMIN check?

Even though the API does not return the mark value, this code allows
the caller to find the mark of any socket simply by performing n=32
socket dumps, each filtering for a mark/mask of 1<<n/1<<n. Each such
dump will reveal bit n in the mark of all sockets in the system.

If you consider socket marks to be information that's private to the
app, then it's appropriate to restrict access to them to NET_ADMIN. I
thought it prudent to do so, particularly since only applications with
NET_ADMIN can set marks in the first place.

Note that a process with NET_ADMIN can already determine the mark of
any given socket (as long as that socket sends a packet) by installing
32 iptables rules that exactly match the socket's 5-tuple and where
each rule checks one bit in the mark. So this patch doesn't expose any
information that was not previously available.
