From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 15:49:51 -0700
Message-ID: <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <20160920224416.GF3291@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34859 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752126AbcITWtw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:49:52 -0400
Received: by mail-qt0-f195.google.com with SMTP id 38so1011745qte.2
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:49:52 -0700 (PDT)
In-Reply-To: <20160920224416.GF3291@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 3:44 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/20/16 at 03:00pm, Tom Herbert wrote:
>> +static inline int __xdp_hook_run(struct list_head *list_head,
>> +                              struct xdp_buff *xdp)
>> +{
>> +     struct xdp_hook_ops *elem;
>> +     int ret = XDP_PASS;
>> +
>> +     list_for_each_entry(elem, list_head, list) {
>> +             ret = elem->hook(elem->priv, xdp);
>> +             if (ret != XDP_PASS)
>> +                     break;
>> +     }
>
> Walking over a linear list? Really? :-) I thought this was supposed
> to be fast, no compromises made.

Can you suggest an alternative?
