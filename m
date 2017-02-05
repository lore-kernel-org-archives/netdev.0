From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next 5/8] net/mlx5e: Calc vlan_tag_present only once on xmit
Date: Sun, 5 Feb 2017 13:22:08 +0200
Message-ID: <CALzJLG_q9gNwrS0yCemoCgkKi38FBkGEkMKTCg9Mij8oLyxgvw@mail.gmail.com>
References: <20170131205843.23235-1-saeedm@mellanox.com> <20170131205843.23235-6-saeedm@mellanox.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0277BF0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f176.google.com ([209.85.216.176]:33019 "EHLO
        mail-qt0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751231AbdBELW3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 06:22:29 -0500
Received: by mail-qt0-f176.google.com with SMTP id v23so83821546qtb.0
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 03:22:29 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0277BF0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 1, 2017 at 1:20 PM, David Laight <David.Laight@aculab.com> wrote:
> From: Saeed Mahameed
>> Sent: 31 January 2017 20:59
>> Cache skb_vlan_tag_present(skb) and pass it wherever needed in xmit
>> routines.
> ...
>
> Does this actually generate better code?

Only in case skb pointer is kept in memory (we will save up to 3
skb->vlan_tci dereferences in that case).

> It is quite likely that your 'vlan_present' variable ends up being on stack.
> Whereas the 'skb' is likely to be in a register.

can i assume this to be likely true on all archs ?

> In which case the two loads are likely to be must the same and your
> change has added a write to the stack.
>
>         David
>
>
