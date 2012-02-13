From: Neal Cardwell <ncardwell@google.com>
Subject: Re: tcp: lost_cnt_hint is -1 due to tcp_shifted_skb() processing
Date: Sun, 12 Feb 2012 22:47:32 -0500
Message-ID: <CADVnQymZ-KDsvCW=G4V+GO2yAuU4_5oaZiHLno-ywv3+S0536g@mail.gmail.com>
References: <CAGK4HS9HxYu6TKX=hvchuxHz7C0vgfhC+2xX2+z8RQTDT1E1Fw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:32877 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298Ab2BMDrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 22:47:33 -0500
Received: by qadc10 with SMTP id c10so1400753qad.19
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2012 19:47:32 -0800 (PST)
In-Reply-To: <CAGK4HS9HxYu6TKX=hvchuxHz7C0vgfhC+2xX2+z8RQTDT1E1Fw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 12, 2012 at 8:13 PM, Vijay Subramanian
<subramanian.vijay@gmail.com> wrote:
> Hi,
>
> With the current net-next, I noticed tp->lost_cnt_hint is -1 in some cases which
> looks like a bug.

Hi Vijay,

I recently noticed the same issue, and our team has been working on a
fix as well. I think your analysis is mostly correct, except that the
suggested fix of moving the call to tcp_sacktag_one() earlier in
tcp_shifted_skb() also will not work, since the end sequence number of
the skb is not the correct value to use in tcp_sacktag_one() (in
addition to the beginning sequence number being incorrect, as you
noted). Tongith I'll send out the patch that we have been working
with.

neal
