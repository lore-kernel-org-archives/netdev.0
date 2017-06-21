From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: fib: fix fib_new_table() logical issue
Date: Wed, 21 Jun 2017 15:53:52 -0700
Message-ID: <CAM_iQpWAeYVkyxKtLFzg7J0H8VcB8VFoU+EUQMQM-2DzMjo04g@mail.gmail.com>
References: <1498053744-3217-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33638 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdFUWyO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 18:54:14 -0400
Received: by mail-wr0-f193.google.com with SMTP id x23so30573082wrb.0
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 15:54:13 -0700 (PDT)
In-Reply-To: <1498053744-3217-1-git-send-email-cugyly@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 7:02 AM, yuan linyu <cugyly@163.com> wrote:
> From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>
> when CONFIG_IP_MULTIPLE_TABLES defined,
> if id == RT_TABLE_LOCAL and !net->ipv4.fib_has_custom_rules,
> fib_new_table() call itself to get RT_TABLE_MAIN table,
> but if RT_TABLE_MAIN table not exist at this point,
> this function will become deadloop.

Why deadloop here? If fib_new_table() is called recursively,
then main table is created by fib_trie_table() and we return.
