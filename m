From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: Re: [Intel-wired-lan] [PATCH 4/6] [net-next]net: i40e: Admin queue
 definitions for cloud filters
Date: Tue, 1 Aug 2017 12:16:15 -0700
Message-ID: <ad9e07cc-3e8d-f6b4-c721-847c8b1cdba7@oracle.com>
References: <150154569340.4135.11548126443780491627.stgit@anamdev.jf.intel.com>
 <150154787489.4135.14606047917479370681.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mitch.a.williams@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>,
        intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:35177 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751938AbdHATPn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 15:15:43 -0400
In-Reply-To: <150154787489.4135.14606047917479370681.stgit@anamdev.jf.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/31/2017 5:37 PM, Amritha Nambiar wrote:
> Add new admin queue definitions and extended fields for cloud
> filter support. Define big buffer for extended general fields
> in Add/Remove Cloud filters command.
> 
> Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> Signed-off-by: Store Laura <laura.stroe@intel.com>
> Signed-off-by: Iremonger Bernard <bernard.iremonger@intel.com>
> Signed-off-by: Jingjing Wu <jingjing.wu@intel.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h |   98 +++++++++++++++++++++
>   1 file changed, 97 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
> index 8bba04c..9f14305 100644
> --- a/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h
> +++ b/drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h

I see that you're changing the i40e version of this, but not the i40evf 
version.  I understand that these changes are not useful for the VF, but 
are you no longer trying to keep the AdminQ definitions consistent 
between the two?

> @@ -1358,7 +1358,9 @@ struct i40e_aqc_add_remove_cloud_filters {
>   #define I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_SHIFT	0
>   #define I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_MASK	(0x3FF << \
>   					I40E_AQC_ADD_CLOUD_CMD_SEID_NUM_SHIFT)
> -	u8	reserved2[4];
> +	u8	big_buffer_flag;
> +#define	I40E_AQC_ADD_REM_CLOUD_CMD_BIG_BUFFER	1
> +	u8	reserved2[3];
>   	__le32	addr_high;
>   	__le32	addr_low;
>   };
> @@ -1395,6 +1397,13 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
>   #define I40E_AQC_ADD_CLOUD_FILTER_IMAC			0x000A
>   #define I40E_AQC_ADD_CLOUD_FILTER_OMAC_TEN_ID_IMAC	0x000B
>   #define I40E_AQC_ADD_CLOUD_FILTER_IIP			0x000C
> +/* 0x0010 to 0x0017 is for custom filters */
> +/* flag to be used when adding cloud filter: IP + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_IP_PORT		0x0010
> +/* flag to be used when adding cloud filter: Dest MAC + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_MAC_PORT		0x0011
> +/* flag to be used when adding cloud filter: Dest MAC + VLAN + L4 Port */
> +#define I40E_AQC_ADD_CLOUD_FILTER_MAC_VLAN_PORT		0x0012
>   
>   #define I40E_AQC_ADD_CLOUD_FLAGS_TO_QUEUE		0x0080
>   #define I40E_AQC_ADD_CLOUD_VNK_SHIFT			6
> @@ -1429,6 +1438,45 @@ struct i40e_aqc_add_remove_cloud_filters_element_data {
>   	u8	response_reserved[7];
>   };

I know you didn't add this struct, but where's the I40E_CHECK_STRUCT_LEN 
check?

>   
> +/* i40e_aqc_add_remove_cloud_filters_element_big_data is used when
> + * I40E_AQC_ADD_REM_CLOUD_CMD_BIG_BUFFER flag is set.
> + */
> +struct i40e_aqc_add_remove_cloud_filters_element_big_data {
> +	struct i40e_aqc_add_remove_cloud_filters_element_data element;
> +	u16     general_fields[32];
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD0	0
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD1	1
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X10_WORD2	2
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD0	3
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD1	4
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X11_WORD2	5
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD0	6
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD1	7
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X12_WORD2	8
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD0	9
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD1	10
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X13_WORD2	11
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD0	12
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD1	13
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X14_WORD2	14
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD0	15
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD1	16
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD2	17
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD3	18
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD4	19
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD5	20
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD6	21
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X16_WORD7	22
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD0	23
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD1	24
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD2	25
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD3	26
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD4	27
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD5	28
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD6	29
> +#define I40E_AQC_ADD_CLOUD_FV_FLU_0X17_WORD7	30
> +};

Needs the I40E_CHECK_STRUCT_LEN to be consistent with the data checking 
in the rest of this file.

> +
>   struct i40e_aqc_remove_cloud_filters_completion {
>   	__le16 perfect_ovlan_used;
>   	__le16 perfect_ovlan_free;
> @@ -1440,6 +1488,54 @@ struct i40e_aqc_remove_cloud_filters_completion {
>   
>   I40E_CHECK_CMD_LENGTH(i40e_aqc_remove_cloud_filters_completion);
>   
> +/* Replace filter Command 0x025F
> + * uses the i40e_aqc_replace_cloud_filters,
> + * and the generic indirect completion structure
> + */
> +struct i40e_filter_data {
> +	u8 filter_type;
> +	u8 input[3];
> +};

Should have I40E_CHECK_STRUCT_LEN check

> +
> +struct i40e_aqc_replace_cloud_filters_cmd {
> +	u8      valid_flags;
> +#define I40E_AQC_REPLACE_L1_FILTER		0x0
> +#define I40E_AQC_REPLACE_CLOUD_FILTER		0x1
> +#define I40E_AQC_GET_CLOUD_FILTERS		0x2
> +#define I40E_AQC_MIRROR_CLOUD_FILTER		0x4
> +#define I40E_AQC_HIGH_PRIORITY_CLOUD_FILTER	0x8
> +	u8      old_filter_type;
> +	u8      new_filter_type;
> +	u8      tr_bit;
> +	u8      reserved[4];
> +	__le32 addr_high;
> +	__le32 addr_low;
> +};

Should have I40E_CHECK_CMD_LENGTH check

> +
> +struct i40e_aqc_replace_cloud_filters_cmd_buf {
> +	u8      data[32];
> +/* Filter type INPUT codes*/
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_ENTRIES_MAX	3
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_VALIDATED	BIT(7)
> +
> +/* Field Vector offsets */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_MAC_DA	0
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_ETH	6
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG	7
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_VLAN	8
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_OVLAN	9
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_STAG_IVLAN	10
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_TUNNLE_KEY	11
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_IMAC	12
> +/* big FLU */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_IP_DA	14
> +/* big FLU */
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_OIP_DA	15
> +
> +#define I40E_AQC_REPLACE_CLOUD_CMD_INPUT_FV_INNER_VLAN	37
> +	struct i40e_filter_data filters[8];
> +};

Should have I40E_CHECK_STRUCT_LEN check

> +
>   /* Add Mirror Rule (indirect or direct 0x0260)
>    * Delete Mirror Rule (indirect or direct 0x0261)
>    * note: some rule types (4,5) do not use an external buffer.
> 
> _______________________________________________
> Intel-wired-lan mailing list
> Intel-wired-lan@osuosl.org
> https://lists.osuosl.org/mailman/listinfo/intel-wired-lan
> 
