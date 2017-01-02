From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] tools: test case for TPACKET_V3/TX_RING support
Date: Mon, 2 Jan 2017 18:15:36 -0500
Message-ID: <CAF=yD-Jr=UNiKyv=tdzvZ2fu5DSb-GTK38R4vyYPcfq1m+EdmQ@mail.gmail.com>
References: <cover.1483309545.git.sowmini.varadhan@oracle.com>
 <d26567a7226d392b8105f35be5cf25a17dbdf2ed.1483309545.git.sowmini.varadhan@oracle.com>
 <CAF=yD-JLDM9cekGTz7m3VYXmf4d+HEMX4dYZx=sB1X7+5drqsA@mail.gmail.com> <20170102230242.GC31716@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:33242 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751763AbdABXQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2017 18:16:17 -0500
Received: by mail-ua0-f194.google.com with SMTP id d5so24824411uag.0
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2017 15:16:17 -0800 (PST)
In-Reply-To: <20170102230242.GC31716@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 2, 2017 at 6:02 PM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
> On (01/02/17 17:31), Willem de Bruijn wrote:
>>
>> Thanks for adding this.
>>
>> walk_v3_tx is almost identical to walk_v1_v2_tx. That function can
>> just be extended to add a v3 case where it already multiplexes between
>> v1 and v2.
>
> I looked at that, but the sticky point is that v1/v2 sets up the
> ring->rd* related variables based on frames (e.g., rd_num is tp_frame_nr)
> whereas V3 sets these up based on blocks (e.g, rd_num is  tp_block_nr)
> so this impacts the core sending loop a bit.

Good point. Yes, deduplicating the function will help make it crystal
clear where v3 differs from v2.

The patch already has __v3_tx_kernel_ready and __v3_tx_user_ready,
which can be plugged into the existing multiplexer functions
__v1_v2_tx_kernel_ready and __v2_v2_tx_user_ready multiplexer
(along with changing their names).

We'll indeed need a similar multiplexer function for calculating the next
frame to work around this rd_num issue, then.
