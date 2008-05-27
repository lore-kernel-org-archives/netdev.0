From: "Dmitry Petukhov" <dmgenp@gmail.com>
Subject: Re: [PATCH 2.6.26-rc4] fix double call of kfree_skb in net/llc/llc_sap.c
Date: Tue, 27 May 2008 14:00:08 +0600
Message-ID: <84ee89da0805270100s3e0da6dbh7dd8f3744b2a6c8f@mail.gmail.com>
References: <84ee89da0805270009xe92f7e1l959fa9161c976db2@mail.gmail.com>
	 <483BB8EF.4090904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	acme@ghostprotocols.net
To: "Wei Yongjun" <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.190]:23379 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754777AbYE0IAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 04:00:13 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1661601tic.23
        for <netdev@vger.kernel.org>; Tue, 27 May 2008 01:00:10 -0700 (PDT)
In-Reply-To: <483BB8EF.4090904@cn.fujitsu.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/5/27 Wei Yongjun <yjwei@cn.fujitsu.com>:
> Not correct, since kfree_skb(skb) is used after skb_get(skb).
>
> First, it used skb_get inc the users counter, and then, kfree_skb will dec
> the users count, not do the real free.

The problem is what there will be one extra call to kfree_skb without
this return, and it will decrease the counter one extra time then.

//sorry for re-post, forgot to CC the list
