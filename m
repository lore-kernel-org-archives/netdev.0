From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v6 04/12] net/mlx4_en: add support for fast rx drop bpf
 program
Date: Sun, 10 Jul 2016 18:25:40 +0300
Message-ID: <57d2eb82-1992-b6fb-0727-b3b0d8983765@gmail.com>
References: <1467944124-14891-1-git-send-email-bblanco@plumgrid.com>
 <1467944124-14891-5-git-send-email-bblanco@plumgrid.com>
 <CALzJLG8+LzX_sELAC-TVszeWXZFbCKVJ+rJnDT50fqN5PodEAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34311 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757170AbcGJPZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jul 2016 11:25:45 -0400
Received: by mail-wm0-f65.google.com with SMTP id w75so13409865wmd.1
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2016 08:25:44 -0700 (PDT)
In-Reply-To: <CALzJLG8+LzX_sELAC-TVszeWXZFbCKVJ+rJnDT50fqN5PodEAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 09/07/2016 10:58 PM, Saeed Mahameed wrote:
> On Fri, Jul 8, 2016 at 5:15 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
>> +               /* A bpf program gets first chance to drop the packet. It may
>> +                * read bytes but not past the end of the frag.
>> +                */
>> +               if (prog) {
>> +                       struct xdp_buff xdp;
>> +                       dma_addr_t dma;
>> +                       u32 act;
>> +
>> +                       dma = be64_to_cpu(rx_desc->data[0].addr);
>> +                       dma_sync_single_for_cpu(priv->ddev, dma,
>> +                                               priv->frag_info[0].frag_size,
>> +                                               DMA_FROM_DEVICE);
> In case of XDP_PASS we will dma_sync again in the normal path, this
> can be improved by doing the dma_sync as soon as we can and once and
> for all, regardless of the path the packet is going to take
> (XDP_DROP/mlx4_en_complete_rx_desc/mlx4_en_rx_skb).
I agree with Saeed, dma_sync is a heavy operation that is now done twice 
for all packets with XDP_PASS.
We should try our best to avoid performance degradation in the flow of 
unfiltered packets.

Regards,
Tariq
