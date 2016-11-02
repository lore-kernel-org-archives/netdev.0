From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next V2 3/3] net/mlx4_en: Add ethtool statistics for
 XDP cases
Date: Wed, 2 Nov 2016 10:18:21 +0200
Message-ID: <f09f2f20-460c-4cd1-3a7b-bba5b9819806@gmail.com>
References: <1478000186-5158-1-git-send-email-tariqt@mellanox.com>
 <1478000186-5158-4-git-send-email-tariqt@mellanox.com>
 <20161101210604.GA29427@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Eran Ben Elisha <eranbe@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: Brenden Blanco <bblanco@plumgrid.com>,
        Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34289 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752139AbcKBISY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 04:18:24 -0400
Received: by mail-wm0-f66.google.com with SMTP id p190so1704868wmp.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 01:18:24 -0700 (PDT)
In-Reply-To: <20161101210604.GA29427@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Brenden,

On 01/11/2016 11:06 PM, Brenden Blanco wrote:
> On Tue, Nov 01, 2016 at 01:36:26PM +0200, Tariq Toukan wrote:
>> XDP statistics are reported in ethtool as follows:
>> - xdp_drop: the number of packets dropped by xdp.
>> - xdp_tx: the number of packets forwarded by xdp.
>> - xdp_tx_full: the number of times an xdp forward failed
>> 	due to a full tx xdp ring.
>>
>> In addition, all packets that are dropped/forwarded by XDP
>> are no longer accounted in rx_packets/rx_bytes of the ring,
>> so that they count traffic that is passed to the stack.
> This seems like a step backwards, in that I now no longer have any
> statistic whatsoever that can count xdp packets per-ring. For instance,
> how would I validate that my flow-hash rules are operating correctly? I
> would suggest to restore the rxN_packet/bytes stat increment.
The per ring counters are there, and I meant to expose them. Somehow 
they were missed.
I'll add them now.
They're going to be like this:
rx0_xdp_drop
rx0_xdp_tx
rx0_xdp_tx_full

>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 14 ++++++++++++++
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  4 ++++
>>   drivers/net/ethernet/mellanox/mlx4/en_port.c    |  6 ++++++
>>   drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 12 +++++++-----
>>   drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  8 ++++----
>>   drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  7 ++++++-
>>   drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h | 10 +++++++++-
>>   7 files changed, 50 insertions(+), 11 deletions(-)
> [...]
Thanks for your comment.

Regards,
Tariq
