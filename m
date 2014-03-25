From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 11/54] atl1c: Call dev_kfree/consume_skb_any instead of
 dev_kfree_skb.
Date: Tue, 25 Mar 2014 06:18:21 -0700
Message-ID: <1395753501.12610.119.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87y4zyhlar.fsf_-_@x220.int.ebiederm.org>
	 <1395727540-12148-1-git-send-email-ebiederm@xmission.com>
	 <1395727540-12148-11-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61855 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbaCYNSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:18:23 -0400
Received: by mail-pb0-f46.google.com with SMTP id rq2so440058pbb.19
        for <netdev@vger.kernel.org>; Tue, 25 Mar 2014 06:18:23 -0700 (PDT)
In-Reply-To: <1395727540-12148-11-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-24 at 23:04 -0700, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm@xmission.com>
> 
> The call path: atl1c_xmit_frame, atlc_tx_rollback, atl1c_clean_buffer
> can not be tell at compile time if it will be invoked from hard irq
> or other context, as atl1c_xmit_frame does not know.  So remove
> the logic that  passes the compile time knowledge into al1c_clean_buffer
> and figure out it out at runtime with dev_consume_skb_any.
> 
> Replace dev_kfree_skb with dev_kfree_skb_any in atl1c_xmit_frame that
> can be called in hard irq and other contexts.
> 
> Replace dev_kfree_skb and dev_kfree_skb_irq with dev_consume_skb_any
> in atl1c_clean_buffer that can be called in hard irq and other
> contexts.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Nice ;)

Acked-by: Eric Dumazet <edumazet@google.com>
