From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net-tun: restructure tun_do_read for better
 sleep/wakeup efficiency
Date: Mon, 19 May 2014 22:11:08 -0700
Message-ID: <1400562668.5367.96.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1400278308-25372-1-git-send-email-xii@google.com>
		 <5379CE8D.2030405@redhat.com>
	 <1400508587.5367.37.camel@edumazet-glaptop2.roam.corp.google.com>
	 <537ADD91.4000609@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Xi Wang <xii@google.com>, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	Maxim Krasnyansky <maxk@qti.qualcomm.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f48.google.com ([209.85.213.48]:54973 "EHLO
	mail-yh0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbaETFLQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 01:11:16 -0400
Received: by mail-yh0-f48.google.com with SMTP id a41so7690207yho.7
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 22:11:15 -0700 (PDT)
In-Reply-To: <537ADD91.4000609@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-05-20 at 12:44 +0800, Jason Wang wrote:
> On 05/19/2014 10:09 PM, Eric Dumazet wrote:

> >
> > About the sk_data_ready() and wake_up_all(), you missed the whole part
> > of the patch I think.
> >
> > Check how sock_def_readable() does everything properly and efficiently,
> > including the async part.
> 
> But this changes (sk_data_ready()) has nothing related to switching to
> use __skb_recv_datagram()
> 

This is totally related.

I think you did not yet understood this patch

Compare wake_up_all() and sk_data_ready() speeds, you'll be surprised.

You should ask to yourself : Why do we use wq_has_sleeper() in
networking stacks ?
