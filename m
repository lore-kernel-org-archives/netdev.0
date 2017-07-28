From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] TLP: Don't reschedule PTO when there's one
 outstanding TLP retransmission.
Date: Fri, 28 Jul 2017 18:57:20 -0400
Message-ID: <CADVnQykJBO_cGrLL6Y_4XPYEt4-WJdp6D2e1MoWrcAcMyFbu0w@mail.gmail.com>
References: <1500971735-21852-1-git-send-email-maowenan@huawei.com>
 <CADVnQykr0YTB7YD=9n04bA8WFBQWku4qsPUZpqgKK6YGmd9xBA@mail.gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F202929B17@DGGEMI512-MBX.china.huawei.com>
 <CAK6E8=ciCn1MFkoPXmBV3k34QxzhwK-yLC5_2hd=bb12dG2jRA@mail.gmail.com> <F95AC9340317A84688A5F0DF0246F3F20292A31A@DGGEMI512-MBX.china.huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yuchung Cheng <ycheng@google.com>, Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Chenweilong <chenweilong@huawei.com>,
        Nandita Dukkipati <nanditad@google.com>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:33211 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752805AbdG1W5v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 18:57:51 -0400
Received: by mail-oi0-f42.google.com with SMTP id a9so144898565oih.0
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 15:57:51 -0700 (PDT)
In-Reply-To: <F95AC9340317A84688A5F0DF0246F3F20292A31A@DGGEMI512-MBX.china.huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 9:28 PM, maowenan <maowenan@huawei.com> wrote:
> Ok, please check as below. Server: 192.169.0.18, client: 192.169.0.17
> ......

Thanks for this trace! Here is a condensed version that I believe
should be equivalent, for those who are working on parsing what's
going on:

2.239562 srv > cli: P 544:616(72) ack 351 win 92
2.240034 srv > cli: P 616:688(72) ack 351 win 92
2.260764 srv > cli: P 616:688(72) ack 351 win 92    # TLP
3.018020 cli > srv: . ack 616 win 1970
3.018386 srv > cli: P 688:760(72) ack 351 win 92    # srv sends B
3.022448 srv > cli: P 760:832(72) ack 351 win 92    # srv sends C
3.033813 cli > srv: P 351:0437(86) ack 616 win 1970 # data/ACK 616
3.034213 cli > srv: P 437:0523(86) ack 616 win 1970 # data/ACK 616
3.034633 srv > cli: . ack 523 win 92
3.039512 cli > srv: P 523:0659(136) ack 616 win 1970
3.040083 cli > srv: P 659:0795(136) ack 616 win 1970
3.040491 srv > cli: . ack 795 win 92
3.041161 cli > srv: P 795:0931(136) ack 616 win 1970
3.042828 cli > srv: P 931:1032(101) ack 616 win 1970
3.043198 srv > cli: . ack 1032 win 92

For the record, I posted my diagnosis of this issue in your thread for
the v2 version of the patch.

thanks,
neal
