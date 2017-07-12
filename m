From: Noa Osherovich <noaos@mellanox.com>
Subject: Re: bug in "PCI: Support INTx masking on ConnectX-4 with firmware
 x.14.1100+"?
Date: Wed, 12 Jul 2017 10:58:22 +0300
Message-ID: <2f3fce8a-61d4-8878-c351-b138ffec6e86@mellanox.com>
References: <CAK1hOcP-+=8SMi8z6zxwqYYcJtSnGHv36Db6fj3Zenux0ViN4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Denys Vlasenko <vda.linux@googlemail.com>,
        netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0045.outbound.protection.outlook.com ([104.47.0.45]:51844
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933181AbdGLH6s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 03:58:48 -0400
In-Reply-To: <CAK1hOcP-+=8SMi8z6zxwqYYcJtSnGHv36Db6fj3Zenux0ViN4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 7/10/2017 7:49 PM, Denys Vlasenko wrote:

> +       /* Reading from resource space should be 32b aligned */
> +       fw_maj_min = ioread32be(fw_ver);
> +       fw_sub_min = ioread32be(fw_ver + 1);
> +       fw_major = fw_maj_min & 0xffff;
> +       fw_minor = fw_maj_min >> 16;
> +       fw_subminor = fw_sub_min & 0xffff;
>
> Maybe second read should be ioread32be(fw_ver + 4)?
>
fw_ver is a pointer:

__be32 __iomem *fw_ver;

Increasing its value means incrementing it by the size of its contents
thus reading the next 32 bits.

Doesn't seem like a bug.

Thanks, Noa
