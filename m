From: Michael Breuer <mbreuer@majjas.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Sun, 17 Jan 2010 18:15:22 -0500
Message-ID: <4B539A0A.2000504@majjas.com>
References: <4B47A81B.5040601@majjas.com> <4B4809EF.1070609@majjas.com>
 <20100109122830.GA4386@del.dom.local> <4B48CC2C.2090403@majjas.com>
 <4B4E2F89.2050606@majjas.com> <20100113210908.GA3065@del.dom.local>
 <4B4E3834.3000609@majjas.com> <4B533A46.9050600@majjas.com>
 <20100117221746.GA3161@del.dom.local> <4B53906B.2020608@majjas.com>
 <20100117230531.GC3161@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta5.srv.hcvlny.cv.net ([167.206.4.200]:63063 "EHLO
	mta5.srv.hcvlny.cv.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280Ab0AQXQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2010 18:16:28 -0500
In-reply-to: <20100117230531.GC3161@del.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/17/2010 6:05 PM, Jarek Poplawski wrote:
> On Sun, Jan 17, 2010 at 05:34:19PM -0500, Michael Breuer wrote:
>    
>> On 1/17/2010 5:17 PM, Jarek Poplawski wrote:
>>      
>>> On Sun, Jan 17, 2010 at 11:26:46AM -0500, Michael Breuer wrote:
>>>        
>>>> On 01/13/2010 04:16 PM, Michael Breuer wrote:
>>>>          
>>>>> On 1/13/2010 4:09 PM, Jarek Poplawski wrote:
>>>>>            
>>>>>> On Wed, Jan 13, 2010 at 03:39:37PM -0500, Michael Breuer wrote:
>>>>>>
>>>>>>              
>>>> Update: after leaving the system up for a few days, I hit the DMAR
>>>> error again.
>>>>          
>>> My proposal is to send some summary as a new thread, with dmar in the
>>> subject, and cc-ed dmar maintainers.
>>>
>>>        
>> Not sure I agree. The symptoms are identical to those I hit without
>> DMAR earlier on. Also, as this issue only happens when there is high
>> receive load, I'm thinking there's some sort of race between TX and
>> RX within the sky2 driver, or hardware. I think that DMAR is
>> correctly catching the error.
>>      
> Hmm... OK, then let's wait with this report and go back to testing
> it "really really long" ;-) without DMAR, and maybe without the
> last Stephen's patch either? (So only the two things in the current
> linux-2.6.)
>
> Jarek P.
>    
Ok - but absent the last patch, I think I still need the pskb_may_pull 
patch... so it'd be pskb_may_pull and afpacket v3 and no DMAR.

Also - not sure if related, but there's still the odd tx side behavior 
when RX is under load. That I CAN reproduce at will (yesterday's report 
- no crash, but I confirmed that DHCPOFFER packets are being dropped 
somewhere after wireshark sees them and before hitting the wire.

I am also wondering whether or not that testing I did yesterday set up 
today's hang - perhaps those lost TX packets are corrupting something 
that manifests worse later.
