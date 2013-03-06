From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH 3/3 net-next] tcp: implement RFC5682 F-RTO
Date: Wed, 6 Mar 2013 16:08:40 -0500
Message-ID: <CADVnQykNC_tVucfu62SdY4CBBNfvCvf-ob7Vg6=14HSPgun+oA@mail.gmail.com>
References: <1362603130-16501-1-git-send-email-ycheng@google.com>
	<1362603130-16501-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	ilpo.jarvinen@cs.helsinki.fi, Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:63392 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753509Ab3CFVIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 16:08:41 -0500
Received: by mail-ee0-f44.google.com with SMTP id l10so6272743eei.31
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 13:08:40 -0800 (PST)
In-Reply-To: <1362603130-16501-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 6, 2013 at 3:52 PM, Yuchung Cheng <ycheng@google.com> wrote:
> This patch implements F-RTO (foward RTO recovery):
>
> When the first retransmission after timeout is acknowledged, F-RTO
> sends new data instead of old data. If the next ACK acknowledges
> some never-retransmitted data, then the timeout was spurious and the
> congestion state is reverted.  Otherwise if the next ACK selectively
> acknowledges the new data, then the timeout was genuine and the
> loss recovery continues. This idea applies to recurring timeouts
> as well. While F-RTO sends different data during timeout recovery,
> it does not (and should not) change the congestion control.
>
> The implementaion follows the three steps of SACK enhanced algorithm
> (section 3) in RFC5682. Step 1 is in tcp_enter_loss(). Step 2 and
> 3 are in tcp_process_loss().  The basic version is not supported
> because SACK enhanced version also works for non-SACK connections.
>
> The new implementation is functionally in parity with the old F-RTO
> implementation except the one case where it increases undo events:
> In addition to the RFC algorithm, a spurious timeout may be detected
> without sending data in step 2, as long as the SACK confirms not
> all the original data are dropped. When this happens, the sender
> will undo the cwnd and perhaps enter fast recovery instead. This
> additional check increases the F-RTO undo events by 5x compared
> to the prior implementation on Google Web servers, since the sender
> often does not have new data to send for HTTP.
>
> Note F-RTO may detect spurious timeout before Eifel with timestamps
> does so.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
