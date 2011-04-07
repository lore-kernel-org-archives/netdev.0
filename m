From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next] cxgb4: don't hold RTNL during ethtool phys_id
Date: Thu, 07 Apr 2011 01:18:51 -0700
Message-ID: <4D9D736B.3050106@chelsio.com>
References: <20110406170929.6e427b36@nehalam>	<201104061720.30219.leedom@chelsio.com> <20110406173308.4737e9d4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Casey Leedom <leedom@chelsio.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13817 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751992Ab1DGITB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 04:19:01 -0400
In-Reply-To: <20110406173308.4737e9d4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 6 Apr 2011 17:20:29 -0700
> Casey Leedom <leedom@chelsio.com> wrote:
> 
>> | From: Stephen Hemminger <shemminger@linux-foundation.org>
>> | Date: Wednesday, April 06, 2011 05:09 pm
>> | 
>> | The Chelsio cxgb4 drivers implement blinking in a unique way by
>> | waiting on the mailbox. This patch cleans it up slightly by no longer
>> | holding the system wide network configuration lock during the process.
>> | 
>> | The patch also uses correct semantics for the time argument
>> | which is supposed to be in seconds; and zero is supposed
>> | to signify infinite blinking.
>> | 
>> | This is still a bad firmware interface design for this
>> | since it means the board is basically hung while doing the blink.
>> | But fixing it correctly would require hardware and firmware
>> | documentation. With that information the device could be converted
>> | to the new set_phys_id.
>> | 
>> | Compile tested only.
>> | 
>> | Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>>   Are you assuming that the firmware won't respond with a command completion 
>> until the LED blinking is complete?  If so, that's a bad assumption.  The 
>> firmware runs as an asynchronous real-time OS.  The LED blinking simply becomes 
>> a thread of activity within the OS and the command completes immediately.
>>
>> Casey
> 
> Then how is LED blinking stopped?

You can pass 0 as blinks to cancel your request, which may or may not cancel 
the LED blinking depending on what other drivers have concurrent blinking 
requests in progress.  But you can't pass UINT_MAX as the patch does.  I'll 
fix it up to use the new ethtool interface this week.
