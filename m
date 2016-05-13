From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 07/13] ipv6: Change "final" protocol processing
 for encapsulation
Date: Fri, 13 May 2016 09:51:02 +0300
Message-ID: <20160513095102.64c80977@halley>
References: <1462985253-2380625-1-git-send-email-tom@herbertland.com>
	<1462985253-2380625-8-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33841 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbcEMGvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2016 02:51:09 -0400
Received: by mail-wm0-f66.google.com with SMTP id n129so1721603wmn.1
        for <netdev@vger.kernel.org>; Thu, 12 May 2016 23:51:09 -0700 (PDT)
In-Reply-To: <1462985253-2380625-8-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 11 May 2016 09:47:27 -0700 Tom Herbert <tom@herbertland.com> wrote:
> When performing foo-over-UDP, UDP packets are processed by the
> encapsulation handler which returns another protocol to process.
> This may result in processing two (or more) protocols in the
> loop that are marked as INET6_PROTO_FINAL. The actions taken
> for hitting a final protocol, in particular the skb_postpull_rcsum
> can only be performed once.
> 
> This patch set adds a check of a final protocol has been seen. The
> rules are:
>   - If the final protocol has not been seen any protocol is processed
>     (final and non-final). In the case of a final protocol, the final
>     actions are taken (like the skb_postpull_rcsum)
>   - If a final protocol has been seen (e.g. an encapsulating UDP
>     header) then no further non-final protocols are allowed
>     (e.g. extension headers). For more final protocols the
>     final actions are not taken (e.g. skb_postpull_rcsum).
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Out of curiousity, you execute the "final actions" on the first
INET6_PROTO_FINAL occurence. Would it make any sense to defer the
actions and do them upon the last INET6_PROTO_FINAL occurence?
Or must them get executed once we encounter the first INET6_PROTO_FINAL
proto handler?

Also, just a nit, seems better if commit title is
  'Ensure "final" protocol processing is performed once'

Thanks
Shmulik
