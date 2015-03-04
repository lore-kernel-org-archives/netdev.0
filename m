From: Pat Erley <pat-lkml@erley.org>
Subject: Re: brcmsmac not compliant to 802.11 for BCM4313
Date: Wed, 04 Mar 2015 11:13:02 -0600
Message-ID: <54F73D1E.80109@erley.org>
References: <1424007136.2042747.227726249.45B6A0E2@webmail.messagingengine.com> <1424094835.3188168.228077393.0E2006F5@webmail.messagingengine.com> <54E2107F.4000709@broadcom.com> <1424112787.3303548.228201005.68F1D224@webmail.messagingengine.com> <54E24B48.80601@broadcom.com> <1424163814.3140549.228461101.1C2E5AB1@webmail.messagingengine.com> <1425483570.3947119.235432705.0D7855AE@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hauke@hauke-m.de, brcm80211-dev-list@broadcom.com,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	brudley@broadcom.com, Franky Lin <frankyl@broadcom.com>,
	meuleman@broadcom.com, linville@tuxdriver.com,
	pieterpg@broadcom.com, hdegoede@redhat.com, wens@csie.org,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Nikita N." <nikitan@operamail.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425483570.3947119.235432705.0D7855AE@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(I don't know why I've been added on this e-mail chain, I'm not in any
  way linked to broadcom or any of their drivers)

On 03/04/2015 09:39 AM, Nikita N. wrote:
> Dear Arend,
> as followup to my last inquiry, since it's passed more than 2 weeks, I'm
> afraid I didn't receive any answer.
> As from subject, I finally discovered that brcmsmac is not compliant to
> 802.11 regulations for BCM4313.
> So, as purchasing customer, and member of Linux users community, I try
> to propose my questions to you again now, 3 in total:

If it's not compliant to 802.11 Regulations, please state in what way 
it's not compliant, and how to reproduce that.  People will take lack of 
compliance seriously.  Read on for what I know about the various parts.

>
> 1) Regulatory domain - you wrote "brcmsmac does assure tx power is
> within regulatory limits by enforcing a world regulatory domain"
> That affirmation is *FALSE*.
> I spent the whole weekend putting brcmsmac under heavy trace, all
> functions, above all the phy ones.
> Some code "supposes" to enforce a regulatory domain, but the effect is
> total null.
> I tried recompile the regulatory domain database, those functions did
> not retrieve the new values.
> Whatever values I set for domain 00, the effect was null - BCM4313 kept
> functioning independently.
> The functions, phy and not, which are "supposed" to set the eeprom
> registries for regdomain enforce, have effect null - the BCM4313 kept
> functioning independently.
> I tried setting random numbers in those functions and registries, the
> effect was null - the BCM4313 kept functioning independently.
> At the edge of my frustration, I started commenting away from the code
> those whole phy functions, the effect was null again - the BCM4313 kept
> functioning independently.
> I don't know for what Broadcom hw device were written and *tested* those
> functions - but sure is, they do *NOT* work for BCM4313.
> Could you please explain how/where the BCM4313 is supposed to "enforcing
> a world regulatory domain" ?

The 'World regulatory domain' is a basic set of rules that you can 
create by taking all of the rules of the world and joining them into 1 
'Most Restricted' set of rules.  It's likely that this is enforced in 
the firmware and not in the driver.  The reason that recompiling the 
regulatory database has no effect is, the firmware probably has it's own 
'determination' of what those rules are.  If you want a device you can 
tweak this stuff on (and possibly end up out of regulatory compliance), 
find one that doesn't include it's own internal regulatory handling. 
The World Regulatory Domain (00) was setup such that it should be legal 
to use everywhere in the world.

>
> 2) MCS - 11n modulated frames are not detected in BCM4313 monitor mode -
> I informed you about this issue more than 1 year ago, and again 2 weeks
> ago.
> The issue still reproduces, and no sign of any fix.
> When/in what backports version, this issue is supposed to be fixed
> finally?

They likely have higher priority 'problems' on their list like getting 
new hardware that doesn't work at all (for any use case) working.  This 
could be a firmware issue and not a driver issue, which would mean 
they'd have to pass the issue to the firmware developers, who are also 
likely working on whatever firmware management says they should be.

>
> 3) I explicitly purchased this BCM4313 already 1 year ago, with the
> following specs: 0x4313 rev 0x01 package 0x08, 3 cores ChipCommon,
> IEEE802.11 and PCIe.
> I have been searching for any technical datasheet specification document
> about BCM4313 on Broadcom website and others.
> Did not find any.
> Could you please send me a detailed technical datasheet specification
> document about BCM4313, for programming/dev purposes?

MOST chip manufacturers won't give you the detailed low level datasheets 
for their wifi chips as often times you can make changes that cause the 
hardware to transmit out of calibrated specs(and potentially damage 
hardware) or outside of legal limits(and risk legal troubles).

>
> Thank you & Greetings
>
>
>
> On Tue, Feb 17, 2015, at 01:03 AM, Nikita N. wrote:
>> Hi Arend,
>>
>>> brcmsmac does assure tx power is within regulatory limits by enforcing a
>>> world regulatory domain. So what is not supported is modifying tx power
>>> settings through user-space.
>>
>> Yes, I believe that could be right, *a* world regulatory domain looks
>> indeed enforced, the USA one only, which is pre-set default inside
>> EEPROM registries device, isn't it?
>>
>>> I know, but that driver is not fully open-source as it links in a binary
>>> blob.
>>
>> AFAIK, also brcmsmac needs at least 2 firmware files to operate, without
>> those nothing works.
>> Isn't it the same concept?
>>
>>> I totally lost track of this one. I am using brcmsmac in monitor mode
>>> using bcm43224 which captures 11n frames just fine. I will give it a try
>>> with a bcm4313. The assoc response in your capture shows undefined MCS
>>> set so maybe there really are no 11n MCS rates used (?).
>>
>> If that was a suggestion about to purchase a bcm43224 or any other
>> Broadcom Corp. product, isn't really convincing, seen the overall
>> support quality Customers are experiencing in here...
>> About my capture file, in the case it was really incomplete someone
>> could have informed me at least a year ago.
>> But anyway no respectable QA Testing team needs a purchasing Customer to
>> help in verifying such enormous issue, isn't it?
>>
>>> Our team consist of two man working full-time on the upstream linux
>>> drivers. So our "customer care" is something that we try to deal with on
>>> the side and admittedly things slip between the cracks.
>>
>> Really, *TWO* men? Are you kidding? Is that how much Broadcom Corp.
>> values the Linux community?
>> Needles to remind, even if Linux users don't pay for the OS license as
>> Windows do, they do pay allright for any Broadcom hardware they
>> purchase!
>> Internet startups which sell a button on internet, they have Dev and QA
>> team 5 times bigger than that!
>> I sense a very gross capacity and resource planning competence issue in
>> here.
>> I kindly ask you, please forward that mail to your higher Managers, on
>> my personal behalf, Thanks.
>>
>> --
>> http://www.fastmail.com - Same, same, but different...
>>
>
