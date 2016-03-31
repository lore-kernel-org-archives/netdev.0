From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 4/8] sock: accept SO_TIMESTAMPING flags in socket cmsg
Date: Wed, 30 Mar 2016 23:36:30 -0400
Message-ID: <CAF=yD-+M1EPLXBpQDO3TczhXZJWJ7=b89nGfzC0ui_W6wW_eBw@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com> <1459377448-2239-5-git-send-email-soheil.kdev@gmail.com>
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
Received: from mail-lf0-f66.google.com ([209.85.215.66]:36261 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbcCaDhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 23:37:12 -0400
Received: by mail-lf0-f66.google.com with SMTP id p81so1382632lfb.3
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 20:37:11 -0700 (PDT)
In-Reply-To: <1459377448-2239-5-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 6:37 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> Accept SO_TIMESTAMPING in control messages of the SOL_SOCKET level
> as a basis to accept timestamping requests per write.
>
> This implementation only accepts TX recording flags (i.e.,
> SOF_TIMESTAMPING_TX_HARDWARE, SOF_TIMESTAMPING_TX_SOFTWARE,
> SOF_TIMESTAMPING_TX_SCHED, and SOF_TIMESTAMPING_TX_ACK) in
> control messages. Users need to set reporting flags (e.g.,
> SOF_TIMESTAMPING_OPT_ID) per socket via socket options.
>
> This commit adds a tsflags field in sockcm_cookie which is
> set in __sock_cmsg_send. It only override the SOF_TIMESTAMPING_TX_*
> bits in sockcm_cookie.tsflags allowing the control message
> to override the recording behavior per write, yet maintaining
> the value of other flags.
>
> This patch implements validating the control message and setting
> tsflags in struct sockcm_cookie. Next commits in this series will
> actually implement timestamping per write for different protocols.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
