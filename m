From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH net-next] sfc: Use ether_addr_copy and eth_broadcast_addr
Date: Wed, 5 Mar 2014 11:48:05 +0000
Message-ID: <53170EF5.1030809@solarflare.com>
References: <alpine.LFD.2.03.1403041449370.13034@solarflare.com> <20140304.153653.263004778768283059.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <sshah@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39334 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203AbaCELsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 06:48:10 -0500
In-Reply-To: <20140304.153653.263004778768283059.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/14 20:36, David Miller wrote:
>> diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
>> index 3b39798..de0c815 100644
>> --- a/drivers/net/ethernet/sfc/ef10.c
>> +++ b/drivers/net/ethernet/sfc/ef10.c
>> @@ -162,8 +162,8 @@ static int efx_ef10_get_mac_address(struct efx_nic *efx, u8 *mac_address)
>>  	if (outlen < MC_CMD_GET_MAC_ADDRESSES_OUT_LEN)
>>  		return -EIO;
>>  
>> -	memcpy(mac_address,
>> -	       MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE), ETH_ALEN);
>> +	ether_addr_copy(mac_address,
>> +	       MCDI_PTR(outbuf, GET_MAC_ADDRESSES_OUT_MAC_ADDR_BASE));
> This is not indented correctly, the original code was.
Oops, yes.
After fixing that, checkpatch also complains about a couple of long
lines (mcdi.c:1207-8).  Am I right in thinking that it's being
overzealous and is best ignored in this case?  Alternatively I suppose
the expression starting 'port_num ? ' could go in a local variable;
would that be clearer?
