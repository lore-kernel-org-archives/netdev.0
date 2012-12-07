From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 2/7] bna: Tx and Rx Optimizations
Date: Fri, 07 Dec 2012 12:46:08 -0500 (EST)
Message-ID: <20121207.124608.444520170061639362.davem@davemloft.net>
References: <1354835868-27016-1-git-send-email-rmody@brocade.com>
	<1354835868-27016-3-git-send-email-rmody@brocade.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B70E5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, adapter_linux_open_src_team@brocade.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755712Ab2LGRqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:46:10 -0500
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70E5@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Fri, 7 Dec 2012 10:46:22 -0000

>>  #define BNA_QE_INDX_ADD(_qe_idx, _qe_num, _q_depth)			\
>>  	((_qe_idx) = ((_qe_idx) + (_qe_num)) & ((_q_depth) - 1))
>> 
>> +#define BNA_QE_INDX_INC(_idx, _q_depth)					\
>> +do {									\
>> +	(_idx)++;							\
>> +	if ((_idx) == (_q_depth))					\
>> +		(_idx) = 0;						\
>> +} while (0)
>> +
> 
> If q_depth has to be a power of 2 (implied by BNA_QE_IND_ADD())
> then you should mask in BNA_QE_INDX_INC() to save the conditional.
> Or just:
> #define BNA_QE_INDX_INC(_idx, _q_depth) BNA_QE_INDX_ADD(_idx, 1, _q_depth)

Agreed.
