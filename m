From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 3/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 1 Nov 2016 14:03:52 -0700
Message-ID: <CACby=pmRFH_2Rnb=bxbkdH0CjAcv2hsCdsPKZssY8A9BS6392w@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <d8c7e07ac7d289a2846af8d659287f3512a4edec.1477959702.git.tgraf@suug.ch>
 <0bfff5e0-cd4a-4d69-d54c-7d6dbf237db7@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:35291 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbcKAVDy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 17:03:54 -0400
Received: by mail-ua0-f172.google.com with SMTP id 12so139143980uas.2
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 14:03:54 -0700 (PDT)
In-Reply-To: <0bfff5e0-cd4a-4d69-d54c-7d6dbf237db7@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 13:11, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 10/31/16 6:37 PM, Thomas Graf wrote:
>>  - Perform simple encapsulation where offload is of no concern.
>>    (The existing funtionality to attach a tunnel key to the skb
>>     and redirect to a tunnel net_device to allow for offload
>>     continues to work obviously).
>
> have you tested the adding of headers with large packets hitting gso and fragmentation? Wondering if mtu is used properly when headers are added and the lwt->headroom is not accounted. See 14972cbd34ff668c390cbd2e6497323484c9e812

Thanks for the pointer David, I will look into this.

The packet size is currently limited to this when adding l2 headers:
skb->dev->mtu + skb->dev->hard_header_len
