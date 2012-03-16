From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: Re: [PATCH net-next] ethtool: Added a field fw dump_state
Date: Fri, 16 Mar 2012 14:10:30 -0700
Message-ID: <CB88F67C.2A1CE%anirban.chakraborty@qlogic.com>
References: <1331922456.2504.0.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe003.messaging.microsoft.com ([213.199.154.141]:31559
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758101Ab2CPVKk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Mar 2012 17:10:40 -0400
In-Reply-To: <1331922456.2504.0.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/16/12 11:27 AM, "Ben Hutchings" <bhutchings@solarflare.com> wrote:

>On Fri, 2012-03-16 at 10:58 -0700, Anirban Chakraborty wrote:
>> From: Manish chopra <manish.chopra@qlogic.com>
>> 
>> This field is added to enable/disable firmware dump.
>> 
>> Signed-off-by: Manish chopra <manish.chopra@qlogic.com>
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
>> ---
>>  include/linux/ethtool.h |    7 +++++++
>>  1 files changed, 7 insertions(+), 0 deletions(-)
>> 
>> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
>> index e1d9e0e..6ebc7de 100644
>> --- a/include/linux/ethtool.h
>> +++ b/include/linux/ethtool.h
>> @@ -666,15 +666,22 @@ struct ethtool_flash {
>>   * 	 %ETHTOOL_GET_DUMP_DATA and this is returned as dump length by
>>driver
>>   * 	 for %ETHTOOL_GET_DUMP_FLAG command
>>   * @data: data collected for get dump data operation
>> + * @dump_state: state of the firmware dump. which can be
>>enable/disable.
>>   */
>> +
>> +#define ETH_FW_DUMP_ENABLE	1
>> +#define ETH_FW_DUMP_DISABLE	0
>> +
>>  struct ethtool_dump {
>>  	__u32	cmd;
>>  	__u32	version;
>>  	__u32	flag;
>>  	__u32	len;
>>  	__u8	data[0];
>> +	__u8	dump_state;
>
>Don't be ridiculous.

Yeah I know, especially when there is a flag field already present there.
The only
reason, we considered for adding it is to keep the backward compatibility
of scripts.
Right now, the flag field sets/gets the dump level of fw. If we use it to
control the
dump state, then it would break the existing scripts, if there are any.

-Anirban
