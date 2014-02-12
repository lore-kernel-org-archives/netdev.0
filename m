From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 04/10] ieee802154: support 100kbps QPSK/EU in
 at86rf230
Date: Wed, 12 Feb 2014 23:01:11 +0300
Message-ID: <52FBD307.9080909@cogentembedded.com>
References: <1392223034-19955-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de> <1392223034-19955-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:38579 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752706AbaBLTBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 14:01:12 -0500
Received: by mail-lb0-f176.google.com with SMTP id w7so7318759lbi.21
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 11:01:11 -0800 (PST)
In-Reply-To: <1392223034-19955-5-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 02/12/2014 07:37 PM, Phoebe Buckheister wrote:

> The standard assigns channel 0 on page 2 to be 100kbps QPSK in the
> 868.3MHz band. Add support to the at86rf230 driver for this channel and
> page, at the moment predicated only for the RF212 chip.

> Per the datasheet, configurations for page 0, channels 0 to 10 and page
> 2, channels 0 to 10 differ only in the BPSK_QPSK bit. Support for
> channels 1 to 10 is untested.

> Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
> ---
>   drivers/net/ieee802154/at86rf230.c |   17 ++++++++++++++---
>   1 file changed, 14 insertions(+), 3 deletions(-)

> diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
> index 99bc822..f6338c4 100644
> --- a/drivers/net/ieee802154/at86rf230.c
> +++ b/drivers/net/ieee802154/at86rf230.c
[...]
> @@ -595,6 +596,14 @@ at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
>   	if (rc < 0)
>   		return rc;
>
> +	if (page == 0)
> +		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 0);
> +	else
> +		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 1);
> +

    Don't think empty line is needed here.

> +	if (rc < 0)
> +		return rc;
> +
>   	return at86rf230_write_subreg(lp, SR_CHANNEL, channel);
>   }
>
[...]
> @@ -1067,9 +1077,10 @@ static int at86rf230_probe(struct spi_device *spi)
>
>   	spi_set_drvdata(spi, lp);
>
> -	if (is_rf212(lp))
> +	if (is_rf212(lp)) {
>   		dev->phy->channels_supported[0] = 0x00007FF;
> -	else
> +		dev->phy->channels_supported[2] = 0x00007FF;
> +	} else
>   		dev->phy->channels_supported[0] = 0x7FFF800;

    Have to use {} in both arms of the *if* statement now -- see 
Documentation/CodingStyle.

WBR, Sergei
