From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] Add eeprom_bad_csum_allow module option to e1000.
Date: Tue, 23 Oct 2007 14:01:21 -0700
Message-ID: <471E6121.9010008@intel.com>
References: <11931515302013-git-send-email-ajax@redhat.com>	 <471E1ECD.80002@intel.com> <1193156487.26974.39.camel@localhost.localdomain> <471E2AD0.1000500@intel.com> <471E5C21.8030908@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Adam Jackson <ajax@redhat.com>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23862 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbXJWVCG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 17:02:06 -0400
In-Reply-To: <471E5C21.8030908@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Adam Jackson wrote:
>>> On Tue, 2007-10-23 at 09:18 -0700, Kok, Auke wrote:
>>>> Adam Jackson wrote:
>>>>> When the EEPROM gets corrupted, you can fix it with ethtool, but
>>>>> only if
>>>>> the module loads and creates a network device.  But, without this
>>>>> option,
>>>>> if the EEPROM is corrupted, the driver will not create a network
>>>>> device.
>>>>>
>>>>> Signed-off-by: Adam Jackson <ajax@redhat.com>
>>>> NAK
>>>>
>>>> wrong list, not sent to me, and while for e100 I was OK with this
>>>> patch, for e1000
>>>> it really does not make sense to 'just allow' a bad checksum - if
>>>> your eeprom is
>>>> randomly messed up then you cannot just fix it like this anyway.
>>> That's strange, I managed to recover an otherwise horked e1000 with it.
>>> What should I have done instead?
>>
>>
>> Dump the eeprom and send us a copy, plus any and all information to
>> the card,
>> system etc.. I realize that you need the patch to actually create it
>> but the
>> danger is that people will start using it *without* troubleshooting
>> the real
>> issue. In various systems the eeprom checksum failure is actually due
>> to a
>> misconfigured powersavings feature and the checksum is really not bad
>> at all, but
>> the card just reports random values.
>>
>> In any case, this patch should not be merged. We often send it around
>> to users to
>> debug their issue in case it involves eeproms, but merging it will
>> just conceal
>> the real issue and all of a sudden a flood of people stop reporting
>> *real* issues
>> to us.
> 
> 
> Sorry, I disagree.  Just as with e100, if there is a clear way the user
> can recover their setup -- and Adam says his was effective -- I don't
> see why we should be denying users the ability to use their own hardware.


That's not even relevant, I already offer the same patch offline to people who
*really* only have a wrong checksum, AFTER we check the contents of their eeprom
for them.

We help everyone out, and if you merge this patch you will prevent users from
getting to us for support in the first place.

I realize that we should probably document the "bad eeprom checksum" case more
decently but I think merging this patch is a bad idea for the *user* in all cases.

You completely bypass the fact that e100 eeproms and e1000 eeproms are completely
different beasts as well, one can be practically empty in all cases (e100), the
other one every bit counts (most e1000's), which is an unfair representation and
falsely tells the user that he can just do this without any information or
disclaimer as to what he may expect afterwards.


Auke
