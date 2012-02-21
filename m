From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH net] macvlan: Disable LRO on lowerdev; warn if it's turned
 back on
Date: Tue, 21 Feb 2012 13:46:47 -0800
Message-ID: <4F4410C7.2000500@candelatech.com>
References: <1329851622.2689.6.camel@bwh-desktop>  <4F43F816.6070908@intel.com> <1329856136.2689.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Shradha Shah <sshah@solarflare.com>,
	Patrick McHardy <kaber@trash.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34870 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755346Ab2BUVrC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:47:02 -0500
In-Reply-To: <1329856136.2689.46.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/21/2012 12:28 PM, Ben Hutchings wrote:
> On Tue, 2012-02-21 at 12:01 -0800, John Fastabend wrote:
>> On 2/21/2012 11:13 AM, Ben Hutchings wrote:
>>> Large Receive Offload (LRO) is only appropriate for packets that are
>>> destined for the host, and should be disabled if received packets may
>>> be forwarded.
>>>
>>> Further, macvtap_skb_to_vnet_hdr() will BUG() on a packet received
>>> with LRO (but not GRO).
>>>
>>> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
>>> ---
>>> I'm not really familiar with macvlan so I'm not certain that this should
>>> be applied to all modes.
>>>
>>> Ben.
>>>
>>>   drivers/net/macvlan.c |    7 +++++++
>>>   1 files changed, 7 insertions(+), 0 deletions(-)
>>>
>>
>> But this patch assumes the macvlan is forwarding traffic to a guest
>> via macvtap. Which is an assumption that may not be true.
>>
>> It seems more appropriate for the macvtap driver to do these checks
>> after all its the driver that may BUG() with LRO.
>
> That's what I thought at first, but then I looked through what macvlan
> was doing and it certainly appears to re-transmit skbs in all modes.
> That's not valid when gso_size != 0 and gso_type == 0.

You can put an IP on a mac-vlan and receive packets on it like
normal Ethernet interfaces.  They wouldn't be re-transmitted
in that case, would they?

>
> Ben.
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
