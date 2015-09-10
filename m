From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCHv1 net] xen-netback: require fewer guest Rx
 slots when not using GSO
Date: Thu, 10 Sep 2015 10:41:40 +0100
Message-ID: <55F15054.1070003@citrix.com>
References: <1441718714-3256-1-git-send-email-david.vrabel@citrix.com>
 <20150909193416.GA15048@l.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23548 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbIJJlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 05:41:44 -0400
In-Reply-To: <20150909193416.GA15048@l.oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/09/15 20:34, Konrad Rzeszutek Wilk wrote:
> On Tue, Sep 08, 2015 at 02:25:14PM +0100, David Vrabel wrote:
>> Commit f48da8b14d04ca87ffcffe68829afd45f926ec6a (xen-netback: fix
>> unlimited guest Rx internal queue and carrier flapping) introduced a
>> regression.
>>
>> The PV frontend in IPXE only places 4 requests on the guest Rx ring.
> 
> in IPXE ? What is that?

ipxe.org

>> Since netback required at least (MAX_SKB_FRAGS + 1) slots, IPXE could
>> not receive any packets.
>>
>> a) If GSO is not enabled on the VIF, fewer guest Rx slots are required
>>    for the largest possible packet.  Calculate the required slots
> 
> s/slots/slot number/
>>    based on the maximum GSO size or the MTU.
>>
>>    This calculation of the number of required slots relies on
>>    1650d5455bd2 (xen-netback: always fully coalesce guest Rx packets)
>>    which present in 4.0-rc1 and later.
>>
>> b) Reduce the Rx stall detection to checking for at least one
> 
> s/to/by/
>>    available Rx request.  This is fine since we're predominately
>>    concerned with detecting interfaces which are down and thus have
>>    zero available Rx requests.
> 
> s/have zero available Rx requests/no available Rx requests/?

If the only review comments you have are unnecessary changes to the
grammar in the commit message, it's probably best if you don't post them.

David
