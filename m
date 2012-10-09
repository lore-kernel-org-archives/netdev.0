From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 2/3] net/mlx4_core: Read HCA frequency and map internal clock
Date: Tue, 9 Oct 2012 21:31:19 +0200
Message-ID: <CAJZOPZJYWighk5sq9naa7zfCEi5oLSNEoo6fMVF5AQ290DHLWw@mail.gmail.com>
References: <1349796013-31106-1-git-send-email-ogerlitz@mellanox.com>
	<1349796013-31106-3-git-send-email-ogerlitz@mellanox.com>
	<1349801661.2386.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:41698 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781Ab2JITbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 15:31:20 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so1055856iag.19
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 12:31:19 -0700 (PDT)
In-Reply-To: <1349801661.2386.8.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 9, 2012 at 6:54 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2012-10-09 at 17:20 +0200, Or Gerlitz wrote:
>> Read HCA frequency, read PCI clock bar and offset, map internal clock to PCI bar.
>
> trivial comments below:
>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> []
>> @@ -1193,8 +1195,31 @@ static void unmap_bf_area(struct mlx4_dev *dev)
>>               io_mapping_free(mlx4_priv(dev)->bf_mapping);
>>  }
>>
>> +static int map_internal_clock(struct mlx4_dev *dev)
>> +{
>> +     struct mlx4_priv *priv = mlx4_priv(dev);
>> +
>> +     priv->clock_mapping = ioremap(pci_resource_start(dev->pdev,
>> +                             priv->fw.clock_bar) +
>> +                             priv->fw.clock_offset, MLX4_CLOCK_SIZE);
>
> I think this is misleading indentation style.

sure, we know what needs to be here, I was under a probably
misconception that checkpatch --strict catches this, thanks for
pointing out


> Perhaps this'd be nicer as something like:
>
>         priv->clock_mapping =
>                 ioremap(pci_resource_start(dev->pdev, priv->fw.clock_bar) +
>                         priv->fw.clock_offset, MLX4_CLOCK_SIZE);
>
> []
>
>> +                     /* In case we got HCA frequency 0 - disable timestamping
>> +                      * to avoid dividing by zero
>> +                      */
>> +                     if (!dev->caps.hca_core_clock) {
>> +                             dev->caps.flags2 &= ~MLX4_DEV_CAP_FLAG2_TS;
>> +                             mlx4_err(dev, "HCA frequency is 0. " \
>> +                                      "Timestamping is not supported.");
>
> These are missing terminating newlines.

OK, will fix


> Please don't split format strings like this.  It's hard to grep.
> Especially please don't use unnecessary line continuations.
> The compiler will concatenate these strings without the \.
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
