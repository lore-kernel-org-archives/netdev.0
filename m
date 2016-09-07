From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] tcp: put a TLV list of TCP stats in error
 queue
Date: Wed, 07 Sep 2016 07:22:37 -0700
Message-ID: <1473258157.10725.28.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473211961-107223-1-git-send-email-francisyyan@gmail.com>
         <1473211961-107223-2-git-send-email-francisyyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
        soheil@google.com, ncardwell@google.com,
        Yuchung Cheng <ycheng@google.com>
To: "Francis Y. Yan" <francisyyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34071 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751201AbcIGOWl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 10:22:41 -0400
Received: by mail-pf0-f175.google.com with SMTP id p64so7255218pfb.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2016 07:22:40 -0700 (PDT)
In-Reply-To: <1473211961-107223-2-git-send-email-francisyyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-06 at 18:32 -0700, Francis Y. Yan wrote:
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
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
