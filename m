From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: Re: [PATCH net-next] ravb: Add fixed-link support
Date: Tue, 15 Dec 2015 19:47:54 +0900
Message-ID: <CAH1o70+SDy=S7nuePAO3KOh6vp7oaYi05Ez04VnDv3LaT3P7Ug@mail.gmail.com>
References: <1450019810-324-1-git-send-email-ykaneko0929@gmail.com>
	<566DDC89.2070804@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>,
	Linux-sh list <linux-sh@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:32794 "EHLO
	mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504AbbLOKr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 05:47:57 -0500
In-Reply-To: <566DDC89.2070804@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2015-12-14 6:00 GMT+09:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> Hello.
>
> On 12/13/2015 06:16 PM, Yoshihiro Kaneko wrote:
>
>> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>>
>> This patch adds support of the fixed PHY.
>> This patch is based on commit 87009814cdbb ("ucc_geth: use the new fixed
>> PHY helpers").
>>
>> Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
>> ---
>>
>> This patch is based on the master branch of David Miller's next networking
>> tree.
>>
>>   drivers/net/ethernet/renesas/ravb_main.c | 12 ++++++++++++
>>   1 file changed, 12 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/renesas/ravb_main.c
>> b/drivers/net/ethernet/renesas/ravb_main.c
>> index 1cf1226..300acb3 100644
>> --- a/drivers/net/ethernet/renesas/ravb_main.c
>> +++ b/drivers/net/ethernet/renesas/ravb_main.c
>
> [...]
>>
>> @@ -887,6 +888,17 @@ static int ravb_phy_init(struct net_device *ndev)
>>
>>         /* Try connecting to PHY */
>>         pn = of_parse_phandle(np, "phy-handle", 0);
>> +       if (!pn) {
>> +               /* In the case of a fixed PHY, the DT node associated
>> +                * to the PHY is the Ethernet MAC DT node.
>> +                */
>> +               if (of_phy_is_fixed_link(np)) {
>> +                       err = of_phy_register_fixed_link(np);
>> +                       if (err)
>> +                               return err;
>> +               }
>> +               pn = np;
>
>
>    I'm seeing that other drivers call of_node_get() here, why don't you?

Thanks.
I sent v2.

>
> [...]
>
> MBR, Sergei
>

Thanks,
kaneko
