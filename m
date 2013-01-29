From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH] [PATCH] tcp: Increment of LINUX_MIB_LISTENOVERFLOWS in
 tcp_v4_conn_request() (updated)
Date: Tue, 29 Jan 2013 09:19:57 -0800
Message-ID: <CAGK4HS-=dY80-8xG0QjK2MVBVM67Xv204JBtF-vfH6m_2F16Lw@mail.gmail.com>
References: <1359337550-3958-1-git-send-email-niveditasinghvi@gmail.com>
	<CAGK4HS9_xZSWVHBQX3DwvR7swnGqqccdD8mvL-i20a2dnOvK1A@mail.gmail.com>
	<CAGK4HS-h77PGp--hvFOPEPJu0ru5uz_K_Aqjo8k2hO=VWBr7Eg@mail.gmail.com>
	<510741B4.9000101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Nivedita Singhvi <niv@us.ibm.com>
To: Nivedita Singhvi <niveditasinghvi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:34443 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab3A2RT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 12:19:57 -0500
Received: by mail-qc0-f171.google.com with SMTP id d1so293285qca.2
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2013 09:19:57 -0800 (PST)
In-Reply-To: <510741B4.9000101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Firstly, before my verbosity here, I'll definitely send in an updated
> version with LISTENDROPS incremented as well as you suggest, separately.
> It gets us towards (1) option I outline below.

Thanks for the updated patch. I have acked it.

>
> The right way to fix that is to agree to what the counters should hold
> and then add the remaining instances where they should be incremented
> (which is what I was sort of half way through). I ran into this while
> debugging a problem of missing packets.
>
> We can:
>
> 1. Consider LISTENDROPS a count of all drops prior to the connection
>    getting ESTABLISHED.  Increment LISTENDROPS everywhere OVERFLOWS
>    is, but also add the increments to LISTENDROPS where we drop the
>    pkt for other reasons.

I think the current code has these semantics. However, prior to your
patch, these counters
were incremented only in tcp_v4_syn_recv_sock().  There may be other
places where we may need to update
these counters.


>
> 2. Remove LISTENDROPS if we don't want to count any other drops, keep
>    only LISTENOVERFLOWS.
>

> Is there anything I'm not seeing here and being a dufus about (likely)?
> Any reason not to do (1)?
>

We cannot remove any counters or change their meaning since they will
break existing applications in my opinion.
So I agree (1) is the best option. The code does this currently but
there may be places where the counters are not getting updated.
We can find and fix these missed updates.

Thanks,
Vijay
