From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH] be2net: hash key for rss-config cmd not set
Date: Tue, 24 May 2011 10:12:31 -0300
Message-ID: <4DDBAEBF.5040901@redhat.com>
References: <edb3e5b8-a38f-4efe-b267-9b5b332f16a4@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sathya Perla <sathya.perla@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45779 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932075Ab1EXNMf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2011 09:12:35 -0400
In-Reply-To: <edb3e5b8-a38f-4efe-b267-9b5b332f16a4@exht1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2011 03:29 AM, Sathya Perla wrote:
> A non-zero, non-descript value is needed as the hash key. The hash variable was left un-initialized; but sometimes it gets a zero value
> and hashing is not effective. The constant value used now (not of any significance) seems to work fine.
> 
> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
> ---
>  drivers/net/benet/be_cmds.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
> index 2463b1c..81654ae 100644
> --- a/drivers/net/benet/be_cmds.c
> +++ b/drivers/net/benet/be_cmds.c
> @@ -1703,7 +1703,8 @@ int be_cmd_rss_config(struct be_adapter *adapter, u8 *rsstable, u16 table_size)
>  {
>  	struct be_mcc_wrb *wrb;
>  	struct be_cmd_req_rss_config *req;
> -	u32 myhash[10];
> +	u32 myhash[10] = {0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF,
> +			0x0123, 0x4567, 0x89AB, 0xCDEF, 0x01EF};
>  	int status;
>  
>  	if (mutex_lock_interruptible(&adapter->mbox_lock))

I know we have the changelog saying that it's not of any significance,
but would be nice to have the same thing in the source as well.

fbl
