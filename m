From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1 net] xen-netback: require fewer guest Rx
 slots when not using GSO
Date: Tue, 15 Sep 2015 11:30:17 +0100
Message-ID: <55F7F339.4050501@citrix.com>
References: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
 <20150909.123459.1956039261743477106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <xen-devel@lists.xenproject.org>
To: David Miller <davem@davemloft.net>, <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:64740 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753027AbbIOKak (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2015 06:30:40 -0400
In-Reply-To: <20150909.123459.1956039261743477106.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/15 20:34, David Miller wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> Date: Tue, 8 Sep 2015 14:25:14 +0100
> 
>> Commit f48da8b14d04ca87ffcffe68829afd45f926ec6a (xen-netback: fix
>> unlimited guest Rx internal queue and carrier flapping) introduced a
>> regression.
>>
>> The PV frontend in IPXE only places 4 requests on the guest Rx ring.
>> Since netback required at least (MAX_SKB_FRAGS + 1) slots, IPXE could
>> not receive any packets.
>>
>> a) If GSO is not enabled on the VIF, fewer guest Rx slots are required
>>    for the largest possible packet.  Calculate the required slots
>>    based on the maximum GSO size or the MTU.
>>
>>    This calculation of the number of required slots relies on
>>    1650d5455bd2 (xen-netback: always fully coalesce guest Rx packets)
>>    which present in 4.0-rc1 and later.
>>
>> b) Reduce the Rx stall detection to checking for at least one
>>    available Rx request.  This is fine since we're predominately
>>    concerned with detecting interfaces which are down and thus have
>>    zero available Rx requests.
>>
>> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> 
> Applied, thanks David.

Hi David,

This is causing regressions with certain frontend drivers.  Can you drop
it, please?

Apologies for posting the patch before running it through the full set
of internal testing.

David
