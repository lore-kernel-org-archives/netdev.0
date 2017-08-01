From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH V3 net-next] TLP: Don't reschedule PTO when there's one
 outstanding TLP retransmission
Date: Mon, 31 Jul 2017 23:04:39 -0400
Message-ID: <CADVnQym0N8Ucd-wzGRG2x7ndAa=JNF35dF9gcBy-sjjNbwzn=A@mail.gmail.com>
References: <1501157337-10900-1-git-send-email-maowenan@huawei.com>
 <CADVnQy=Dw__BrTHwoUrn0Wxu8=Xb7NqZ9bAuEeM8SrNhzd_2SA@mail.gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F2029326B6@DGGEMI512-MBX.china.huawei.com>
 <CADVnQykeDvPCQqvoox-oQkm5FdCvLQRvxZKC+TVmG7g-9CEoxw@mail.gmail.com>
 <F95AC9340317A84688A5F0DF0246F3F202932CA2@DGGEMI512-MBX.china.huawei.com> <CADVnQymVniXHxEDW8aA8z+M=G_qNfo+jJfUBrfHycM4-voiDJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        "weiyongjun (A)" <weiyongjun1@huawei.com>,
        Chenweilong <chenweilong@huawei.com>,
        "Wangkefeng (Kevin)" <wangkefeng.wang@huawei.com>
To: maowenan <maowenan@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:35496 "EHLO
        mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751759AbdHADFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 23:05:11 -0400
Received: by mail-oi0-f54.google.com with SMTP id e124so3817219oig.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 20:05:10 -0700 (PDT)
In-Reply-To: <CADVnQymVniXHxEDW8aA8z+M=G_qNfo+jJfUBrfHycM4-voiDJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 31, 2017 at 11:49 AM, Neal Cardwell <ncardwell@google.com> wrote:
> On Sun, Jul 30, 2017 at 11:29 PM, maowenan <maowenan@huawei.com> wrote:
>> [Mao Wenan]please refer to the attachment, test.pkt is packetdrill script.
>> In test.pcap, packet number 17 is the TLP probe, packet number 218 is the
>> retransmission packet because client don't send data packet to server.
>> From the capture time, there are about 6 seconds the retransmission
>> packet can be sent, and this time can be added more as long as client
>> send data packet continually.
>> I have reproduced this issue in Linux 4.13-rc3, 3.10, 4.1. Please check the timing
>> When you use test.pkt to reproduce in your environment.
>
> Thank you for your very nice packetdrill test case illustrating this
> problem! And thanks for verifying that the problem shows up in those
> kernel versions.
>
> We are able to run the script in our environment and both verify that
> the bug is the one we hypothesized, and verify our  proposed patch
> fixes it (the RTO for the TLP happens 221ms after the TLP, instead of
> ~5 secs later). We will send out our proposed patches ASAP.

The timer patches are upstream for review for the "net" branch:

  https://patchwork.ozlabs.org/patch/796057/
  https://patchwork.ozlabs.org/patch/796058/
  https://patchwork.ozlabs.org/patch/796059/

Again, thank you for reporting this and providing a packetdrill script
to reproduce this!

neal
