From: "Ma Lin" <gavin.malin@gmail.com>
Subject: FACK and CWND
Date: Fri, 28 Jul 2006 18:37:15 +0800
Message-ID: <c583c3410607280337y5a9b1276gda0f00259ce1995f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.233]:2747 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S932625AbWG1KhQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 06:37:16 -0400
Received: by wr-out-0506.google.com with SMTP id i3so226937wra
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2006 03:37:15 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there,
A question related to TCP-FACK, which is a default in Linux:

In FACK, the holes between SACK blocks are considered as loss. To a
sender, when SACK comes in, loss_out would be non-zero. According to
linux-2.6.17.7/net/ipv4/tcp_input.c, function tcp_time_to_recover(),
this non-zero
loss_out will send the sender into "Recovery" state, in which, CWND could
be reduced. In one word, it seems that, FACK would allow SACK holes to
reduce CWND.

However, in the paper "Congestion Control in Linux TCP", Section 3,
subsection Recovery, it says that
Recovery state is triggered by "sufficient amount of successive duplicate
ACK", to my understand, that means 3-dup. And in Section 3, subsection
Disorder, it is also mentioned, SACK cause the sender move into this state.
Therefore, I suppose it means SACK holes won't reduce CWND, they merely
trigger fast_retrans and fast_recover. Even in the net/ipv4/tcp_input.c file, in
the large block of comment right above the function tcp_time_to_recover(),
it is also mentioned, CWND should only changed by "claasic VJ rules", which
again means, CWND should only changes to 3-dup (or timeout).

So, which is correct? The implementation, or the document? Or most probabally,
am I wrong somewhere?

Thank you guys!

malin
