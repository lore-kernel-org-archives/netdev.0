From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [e1000]:  flow control on by default - good idea really?
Date: Wed, 05 Jul 2006 09:23:54 -0700
Message-ID: <44ABE79A.1060603@intel.com>
References: <1152033116.5276.22.camel@jzny2> <1152040839.5276.25.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	john.ronciak@intel.com, Ben Greear <greearb@candelatech.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:2385 "EHLO
	fmsmga101-1.fm.intel.com") by vger.kernel.org with ESMTP
	id S964859AbWGEQZC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 12:25:02 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152040839.5276.25.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-04-07 at 13:11 -0400, jamal wrote:
>> I have a device connected to a e1000 that was erroneously advertising
>> both tx/rx flow control but wasnt properly reacting to it. 
>> The default setup on the e1000 has rx flow control turned on.
>> I was sending at wire rate gige from the device - which is about
>> 1.48Mpps. The e1000 was in turn sending me flow control packets
>> as per default/expected behavior. Unfortunately, it was sending
>> a very large amount of packets. At one point i was seeing upto
>> 1Mpps and on average, the flow control packets were consuming
>> 60-70% of the bandwidth. Even when i fixed this behavior to act
>> properly, allowing flow control on consumed up to 15% of the bandwidth. 
>> Clearly, this is a bad thing. Yes, the device in the first instance was
>> at fault. But i have argued in the past that NAPI does just fine without
>> flow control being turned on, so even chewing 5% of bandwidth on flow
>> control is a bad thing..
>>
>> As a compromise, can we declare flow control as an advanced feature
>> and turn it off by default? People who feel it is valuable and know
>> what they are doing can turn it off.
> 
> I meant turn it on.
> 
> BTW, As an addendum this default behavior changed around 2.6.16 it
> seems.

Flow Control is using the EEPROM provided value, the module driver itself does 
not choose a default:

e1000_param.c:

/* User Specified Flow Control Override
  *
  * Valid Range: 0-3
  *  - 0 - No Flow Control
  *  - 1 - Rx only, respond to PAUSE frames but do not generate them
  *  - 2 - Tx only, generate PAUSE frames but ignore them on receive
  *  - 3 - Full Flow Control Support
  *
  * Default Value: Read flow control settings from the EEPROM
  */

Turning flow control off usually (i.e. almost always) causes (significantly) 
_degraded_ performance. We should really leave it the way it is (as per eeprom 
setting), and this is best for most if not all people. The card itself has 
this value programmed, which makes it possible for the user to turn on/off 
flowcontrol per card consistently, which makes much more sense to me. Also 
considering e1000 hardware varies significantly.

Moreover, most support calls here where people complain about degraded 
performance are about users who turned flow control _off_. :)


Cheers,

Auke
