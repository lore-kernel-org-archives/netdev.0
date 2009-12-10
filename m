From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC PATCH 01/12] ixgbe: Mailbox header and code module
Date: Wed, 9 Dec 2009 16:53:35 -0800
Message-ID: <43F901BD926A4E43B106BF17856F07558C3DED55@orsmsx508.amr.corp.intel.com>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
 <20091210005018.GH4163@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Simon Horman <horms@verge.net.au>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41846 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753687AbZLJAxb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2009 19:53:31 -0500
In-Reply-To: <20091210005018.GH4163@verge.net.au>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Simon Horman [mailto:horms@verge.net.au]
>Sent: Wednesday, December 09, 2009 4:50 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Rose, Gregory V;
>Waskiewicz Jr, Peter P
>Subject: Re: [RFC PATCH 01/12] ixgbe: Mailbox header and code module
>

[Rose, Gregory V] 

Further snippage

>
>> +/**
>> + *  ixgbe_init_mbx_params_pf - set initial values for pf mailbox
>> + *  @hw: pointer to the HW structure
>> + *
>> + *  Initializes the hw->mbx struct to correct values for pf mailbox
>> + */
>> +s32 ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
>> +{
>> +	struct ixgbe_mbx_info *mbx = &hw->mbx;
>> +
>> +	if (hw->mac.type == ixgbe_mac_82599EB) {
>> +		mbx->timeout = 0;
>> +		mbx->usec_delay = 0;
>> +
>> +		mbx->size = IXGBE_VFMAILBOX_SIZE;
>> +
>> +		mbx->stats.msgs_tx = 0;
>> +		mbx->stats.msgs_rx = 0;
>> +		mbx->stats.reqs = 0;
>> +		mbx->stats.acks = 0;
>> +		mbx->stats.rsts = 0;
>> +	}
>> +
>> +	return 0;
>> +}
>
>Does ixgbe_init_mbx_params_pf() need a return value?
>The only caller seems to ignore it.
[Rose, Gregory V] 

I guess not then.  Noted.

>
>Also, I prefer the following idiom, but in this case
>it doesn't seem to offer any advantage:
>
>void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
>{
>	struct ixgbe_mbx_info *mbx = &hw->mbx;
>
>	if (hw->mac.type != ixgbe_mac_82599EB)
>		return;
>
>	mbx->timeout = 0;
>	mbx->usec_delay = 0;
>
>	mbx->size = IXGBE_VFMAILBOX_SIZE;
>
>	mbx->stats.msgs_tx = 0;
>	mbx->stats.msgs_rx = 0;
>	mbx->stats.reqs = 0;
>	mbx->stats.acks = 0;
>	mbx->stats.rsts = 0;
>}
[Rose, Gregory V] 

Fewer lines of unnecessary text are a good thing.  Also noted.

- Greg

