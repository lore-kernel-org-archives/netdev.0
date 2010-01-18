From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Mon, 18 Jan 2010 07:30:18 +0000
Message-ID: <20100118073018.GA6270@ff.dom.local>
References: <20100109122830.GA4386@del.dom.local> <4B48CC2C.2090403@majjas.com> <4B4E2F89.2050606@majjas.com> <20100113210908.GA3065@del.dom.local> <4B4E3834.3000609@majjas.com> <4B533A46.9050600@majjas.com> <20100117221746.GA3161@del.dom.local> <4B53906B.2020608@majjas.com> <20100117230531.GC3161@del.dom.local> <4B539A0A.2000504@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:60957 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab0ARHa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 02:30:26 -0500
Content-Disposition: inline
In-Reply-To: <4B539A0A.2000504@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 17, 2010 at 06:15:22PM -0500, Michael Breuer wrote:
> On 1/17/2010 6:05 PM, Jarek Poplawski wrote:
>> On Sun, Jan 17, 2010 at 05:34:19PM -0500, Michael Breuer wrote:
>>    
>>> On 1/17/2010 5:17 PM, Jarek Poplawski wrote:
>>>      
>>>> On Sun, Jan 17, 2010 at 11:26:46AM -0500, Michael Breuer wrote:
>>>>        
>>>>> On 01/13/2010 04:16 PM, Michael Breuer wrote:
>>>>>          
>>>>>> On 1/13/2010 4:09 PM, Jarek Poplawski wrote:
>>>>>>            
>>>>>>> On Wed, Jan 13, 2010 at 03:39:37PM -0500, Michael Breuer wrote:
>>>>>>>
>>>>>>>              
>>>>> Update: after leaving the system up for a few days, I hit the DMAR
>>>>> error again.
>>>>>          
>>>> My proposal is to send some summary as a new thread, with dmar in the
>>>> subject, and cc-ed dmar maintainers.
>>>>
>>>>        
>>> Not sure I agree. The symptoms are identical to those I hit without
>>> DMAR earlier on. Also, as this issue only happens when there is high
>>> receive load, I'm thinking there's some sort of race between TX and
>>> RX within the sky2 driver, or hardware. I think that DMAR is
>>> correctly catching the error.
>>>      
>> Hmm... OK, then let's wait with this report and go back to testing
>> it "really really long" ;-) without DMAR, and maybe without the
>> last Stephen's patch either? (So only the two things in the current
>> linux-2.6.)
>>
>> Jarek P.
>>    
> Ok - but absent the last patch, I think I still need the pskb_may_pull  
> patch... so it'd be pskb_may_pull and afpacket v3 and no DMAR.

Exactly. Or if it's working for you already, the mainline (2.6.33-rc4)
with the pskb_may_pull patch. And check for warnings from the latter.

>
> Also - not sure if related, but there's still the odd tx side behavior  
> when RX is under load. That I CAN reproduce at will (yesterday's report  
> - no crash, but I confirmed that DHCPOFFER packets are being dropped  
> somewhere after wireshark sees them and before hitting the wire.

I'm not sure either, but until there is no crash it might be some
minor bug or/and missing stat. Btw, you could probably try alternative
test with ping from this overloaded box to the router and win7.

>
> I am also wondering whether or not that testing I did yesterday set up  
> today's hang - perhaps those lost TX packets are corrupting something  
> that manifests worse later.

Maybe, but you wrote earlier they had to fix something around this
DMAR in the meantime, because it triggered much faster during your
previous tests. So, I don't know why you assume this DMAR has to be
correct this time.

Jarek P.
