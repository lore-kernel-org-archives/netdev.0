From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH] wireless: mwifiex: remove unreachable paths
Date: Thu, 20 Dec 2012 12:13:44 -0800
Message-ID: <477F20668A386D41ADCC57781B1F70430D13D806CA@SC-VEXCH1.marvell.com>
References: <1356030701-16284-1-git-send-email-sasha.levin@oracle.com>
 <1356030701-16284-17-git-send-email-sasha.levin@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sasha Levin <sasha.levin@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1356030701-16284-17-git-send-email-sasha.levin@oracle.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sasha,

Thanks for the patch.

> We know 'firmware' is non-NULL from the beginning of mwifiex_prog_fw_w_helper,
> remove all !firmware paths from the rest of the function.

After removing all !firmware paths the function 'mwifiex_get_fw_data' becomes an orphan.

Could you please remove that function as well and resend a v2 patch?

Thanks,
Bing

> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  drivers/net/wireless/mwifiex/usb.c | 15 +++------------
>  1 file changed, 3 insertions(+), 12 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwifiex/usb.c
> index 63ac9f2..8bd7098 100644
> --- a/drivers/net/wireless/mwifiex/usb.c
> +++ b/drivers/net/wireless/mwifiex/usb.c
> @@ -836,23 +836,14 @@ static int mwifiex_prog_fw_w_helper(struct mwifiex_adapter *adapter,
>  			dlen = 0;
>  		} else {
>  			/* copy the header of the fw_data to get the length */
> -			if (firmware)
> -				memcpy(&fwdata->fw_hdr, &firmware[tlen],
> -				       sizeof(struct fw_header));
> -			else
> -				mwifiex_get_fw_data(adapter, tlen,
> -						    sizeof(struct fw_header),
> -						    (u8 *)&fwdata->fw_hdr);
> +			memcpy(&fwdata->fw_hdr, &firmware[tlen],
> +			       sizeof(struct fw_header));
> 
>  			dlen = le32_to_cpu(fwdata->fw_hdr.data_len);
>  			dnld_cmd = le32_to_cpu(fwdata->fw_hdr.dnld_cmd);
>  			tlen += sizeof(struct fw_header);
> 
> -			if (firmware)
> -				memcpy(fwdata->data, &firmware[tlen], dlen);
> -			else
> -				mwifiex_get_fw_data(adapter, tlen, dlen,
> -						    (u8 *)fwdata->data);
> +			memcpy(fwdata->data, &firmware[tlen], dlen);
> 
>  			fwdata->seq_num = cpu_to_le32(fw_seqnum);
>  			tlen += dlen;
> --
> 1.8.0
