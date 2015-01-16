From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Compile-time warnings on mlx4/net-next
Date: Fri, 16 Jan 2015 12:45:26 +0100
Message-ID: <54B8F9D6.4050202@redhat.com>
References: <54B7BB17.8090308@redhat.com> <54B7BEAF.6000406@mellanox.com> <54B7C2EB.8010007@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@mellanox.com>, netdev <netdev@vger.kernel.org>
To: Marcelo Ricardo Leitner <mleitner@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754525AbbAPLpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jan 2015 06:45:33 -0500
In-Reply-To: <54B7C2EB.8010007@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/15/2015 02:38 PM, Marcelo Ricardo Leitner wrote:
> On 15-01-2015 11:20, Or Gerlitz wrote:
...
>>> Do you see them too?
>>
>> using $ make W=1 -j 20 SUBDIRS=./drivers/net/ethernet/mellanox/mlx4 with gcc
>> 4.8.2 I don't see that, but I'll look there,
>> thanks for the report.

I believe they are there for quite some time already. I'm using gcc 4.8.3
and just default build. I'm surprised Fengguang didn't complain yet (or
he did, but it got ignored somehow ;)). The following should be sufficient
to just shut gcc up:

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 982861d..b01154d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -2122,6 +2122,7 @@ int mlx4_config_dev_retrieval(struct mlx4_dev *dev,
  	if (!(dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_CONFIG_DEV))
  		return -ENOTSUPP;

+	memset(&config_dev, 0, sizeof(config_dev));
  	err = mlx4_CONFIG_DEV_get(dev, &config_dev);
  	if (err)
  		return err;
