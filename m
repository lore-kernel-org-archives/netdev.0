From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx4_en: Extend checksum offloading by
 CHECKSUM COMPLETE
Date: Fri, 31 Oct 2014 15:52:43 +0200
Message-ID: <CAJ3xEMiR1aaVYJQ_Q+ZEyhxbm3vxxu7pE5e13GWfmesDZO0Yxg@mail.gmail.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	<1414685216-28907-9-git-send-email-ogerlitz@mellanox.com>
	<CAKQ1sVNu9AN=gaRQfgqWq635YBZjEHegz0Ljj3xvvcDSoFaU=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Jerry Chu <hkchu@google.com>
To: Yann Ylavic <ylavic.dev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f177.google.com ([209.85.214.177]:47104 "EHLO
	mail-ob0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757863AbaJaNwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 09:52:44 -0400
Received: by mail-ob0-f177.google.com with SMTP id m8so5699191obr.36
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 06:52:43 -0700 (PDT)
In-Reply-To: <CAKQ1sVNu9AN=gaRQfgqWq635YBZjEHegz0Ljj3xvvcDSoFaU=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2014 at 2:38 AM, Yann Ylavic <ylavic.dev@gmail.com> wrote:
> Hi,
>
> On Thu, Oct 30, 2014 at 5:06 PM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> [...]
>> +static int check_csum(struct mlx4_cqe *cqe, struct sk_buff *skb, int hwtstamp_rx_filter)
>> +{
>> +       __wsum hw_checksum = 0;
>> +
>> +       void *hdr = (u8 *)skb->data + sizeof(struct ethhdr);
>> +
>> +       hw_checksum = csum_unfold((__force __sum16)cqe->checksum);
>> +
>> +       if (((struct ethhdr *)skb->data)->h_proto == htons(ETH_P_8021Q) &&
>> +           hwtstamp_rx_filter != HWTSTAMP_FILTER_NONE) {
>> +               /* next protocol non IPv4 or IPv6 */
>> +               if (((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
>> +                   != htons(ETH_P_IP) ||
>
> Shouldn't this be a AND (&&)?

Oh, yes of course, good catch (this protects against the case of QinQ
which isn't supported, so somehow passed the testing... Shani, please
fix it up.

Or.

>
>> +                   ((struct vlan_hdr *)hdr)->h_vlan_encapsulated_proto
>> +                   != htons(ETH_P_IPV6))
>> +                       return -1;
