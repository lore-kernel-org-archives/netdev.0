From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 7/8] sock: enable timestamping using control messages
Date: Wed, 30 Mar 2016 23:39:09 -0400
Message-ID: <CAF=yD-LP93PHb=fr3UCFtZhcSehsoO=oYvk09JhRTwXutfT25w@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com> <1459377448-2239-8-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:33544 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbcCaDju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 23:39:50 -0400
Received: by mail-lb0-f193.google.com with SMTP id bc4so5802299lbc.0
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 20:39:49 -0700 (PDT)
In-Reply-To: <1459377448-2239-8-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 6:37 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> Currently, SOL_TIMESTAMPING can only be enabled using setsockopt.
> This is very costly when users want to sample writes to gather
> tx timestamps.
>
> Add support for enabling SO_TIMESTAMPING via control messages by
> using tsflags added in `struct sockcm_cookie` (added in the previous
> patches in this series) to set the tx_flags of the last skb created in
> a sendmsg. With this patch, the timestamp recording bits in tx_flags
> of the skbuff is overridden if SO_TIMESTAMPING is passed in a cmsg.
>
> Please note that this is only effective for overriding the recording
> timestamps flags. Users should enable timestamp reporting (e.g.,
> SOF_TIMESTAMPING_SOFTWARE | SOF_TIMESTAMPING_OPT_ID) using
> socket options and then should ask for SOF_TIMESTAMPING_TX_*
> using control messages per sendmsg to sample timestamps for each
> write.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
