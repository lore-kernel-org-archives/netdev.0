From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net] be2net: Warn users of possible broken functionality
 on BE2 cards with very old F/W versions with latest driver.
Date: Thu, 3 Oct 2013 20:45:36 +0100
Message-ID: <1380829536.3419.7.camel@bwh-desktop.uk.level5networks.com>
References: <e84f68dc-6ab3-4e56-b2f5-70e51c46d1c3@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Somnath Kotur <somnath.kotur@emulex.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50037 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755120Ab3JCTpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Oct 2013 15:45:40 -0400
In-Reply-To: <e84f68dc-6ab3-4e56-b2f5-70e51c46d1c3@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-03 at 12:33 +0530, Somnath Kotur wrote:
> On very old F/W versions < 4.0, the mailbox command to set interrupts on the
> card succeeds even though it is not supported and should have failed leading to
> interrupts not working.
> Hence warn users to upgrade to a suitable F/W version to avoid seeing broken
> functionality.
> 
> Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
> ---
>  drivers/net/ethernet/emulex/benet/be_main.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
> index 2c38cc4..f4bbc92 100644
> --- a/drivers/net/ethernet/emulex/benet/be_main.c
> +++ b/drivers/net/ethernet/emulex/benet/be_main.c
> @@ -3247,6 +3247,11 @@ static int be_setup(struct be_adapter *adapter)
>  
>  	be_cmd_get_fw_ver(adapter, adapter->fw_ver, adapter->fw_on_flash);
>  
> +	if (BE2_chip(adapter) && memcmp(adapter->fw_ver, "4.", 2) < 0) {

Are you sure the firmware major version will never go up to 2 digits?
This seems like a job for simple_strtol(), except that's now deprecated.
I don't know what one is supposed to do now when parsing a string that
has more than just a single integer in it.

> +		dev_err(dev, "F/W version is very old. IRQs may not work\n");
> +		dev_err(dev, "Pls upgrade to F/W version >= 4.0\n");

'Please' is spelt thus.  And it seems odd to say 'very old' when you
also have a very specific idea of how old that is (< 4.0).

Ben.

> +	}
> +
>  	if (adapter->vlans_added)
>  		be_vid_config(adapter);
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
