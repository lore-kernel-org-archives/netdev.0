From: Saeed Mahameed <saeedm@mellanox.com>
Subject: Re: [PATCH net-next 6/6] net/mlx5: Add handling for port module event
Date: Wed, 31 Aug 2016 14:05:27 +0300
Message-ID: <57C6B9F7.306@mellanox.com>
References: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
 <1472556595-9286-7-git-send-email-saeedm@mellanox.com>
 <CAJ3xEMg9d58BwLR3QAK_WjmLM1Sz2RrCDUJxQbeLzPAW7Hwp2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Huy Nguyen <huyn@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0065.outbound.protection.outlook.com ([104.47.2.65]:63648
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753231AbcIAHm5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Sep 2016 03:42:57 -0400
In-Reply-To: <CAJ3xEMg9d58BwLR3QAK_WjmLM1Sz2RrCDUJxQbeLzPAW7Hwp2Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 8/30/2016 11:24 PM, Or Gerlitz wrote:
> On Tue, Aug 30, 2016 at 2:29 PM, Saeed Mahameed <saeedm@mellanox.com> wrote:
>> From: Huy Nguyen <huyn@mellanox.com>
>> +++ b/include/linux/mlx5/device.h
>> @@ -543,6 +544,15 @@ struct mlx5_eqe_vport_change {
>>          __be32          rsvd1[6];
>>   } __packed;
>>
>> +struct mlx5_eqe_port_module {
>> +       u8        rsvd0[1];
>> +       u8        module;
>> +       u8        rsvd1[1];
>> +       u8        module_status;
>> +       u8        rsvd2[2];
>> +       u8        error_type;
>> +};
>> +
> Saeed, any reason for this struct and friends not to be  @ the FW IFC file?

Yes, those structures are accessed from irq context, we need to keep it 
as fast as possible,
although for this case it is not that critical. But in order to keep the 
code uniform, all eqes are built this way.
