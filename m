From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next 2/2] tcp: put a TLV list of TCP stats in error queue
Date: Wed, 7 Sep 2016 01:04:38 -0400
Message-ID: <CACSApvYRcBLLc9QZmts7CDxRcqaF+g4fJsGY52t7jDWXy3fw9g@mail.gmail.com>
References: <1473211961-107223-1-git-send-email-francisyyan@gmail.com> <1473211961-107223-2-git-send-email-francisyyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: "Francis Y. Yan" <francisyyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33257 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbcIGFFT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 01:05:19 -0400
Received: by mail-oi0-f42.google.com with SMTP id y2so11014538oie.0
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 22:05:19 -0700 (PDT)
In-Reply-To: <1473211961-107223-2-git-send-email-francisyyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 6, 2016 at 9:32 PM, Francis Y. Yan <francisyyan@gmail.com> wrote:
>
> To export useful TCP statistics along with timestamps, such as
> rwnd-limited time and min RTT, we enqueue a TLV list in error queue
> immediately when a timestamp is generated.
>
> Specifically, if user space requests SOF_TIMESTAMPING_TX_* timestamps
> and sets SOF_TIMESTAMPING_OPT_STATS, the kernel will create a list of
> TLVs (struct nlattr) containing all the statistics and store the list
> in payload of the skb that is going to be enqueued into error queue.
> Notice that SOF_TIMESTAMPING_OPT_STATS can only be set together with
> SOF_TIMESTAMPING_OPT_TSONLY.
>
> In addition, if the application in user space also enables receiving
> timestamp (e.g. by SOF_TIMESTAMPING_SOFTWARE), calling recvfrom() on
> error queue will return one more control message with a cmsg_type of
> SCM_OPT_STATS containing the list of TLVs in its cmsg_data.
>
> Signed-off-by: Francis Y. Yan <francisyyan@gmail.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
