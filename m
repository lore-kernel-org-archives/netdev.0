From: John <linux.kernel@free.fr>
Subject: Re: Intel 82559 NIC corrupted EEPROM
Date: Wed, 07 Feb 2007 12:06:35 +0100
Message-ID: <45C9B2BB.3010404@free.fr>
References: <fa.FcMVUlqOXU3cAnxsPEN6d8T0wxU@ifi.uio.no> <fa.0FC8eT8GQaLxmNQTrsqyNFjRK4E@ifi.uio.no> <fa.nds0CFkNbotWh4VNM05EixY68wE@ifi.uio.no> <fa.K3Gpuu7oYQv+4q85Ziy3ljV6u+E@ifi.uio.no> <fa./RNOPU0DwWMrnKJSqlMaY+Y16JM@ifi.uio.no> <fa.yV32AYzot0OkvPVCY7VTCvd6rJw@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@gmail.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com, bunk@stusta.de,
	jgarzik@pobox.com, saw@saw.sw.com.sg, linux.kernel@free.fr
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161181AbXBGLIk@vger.kernel.org>
In-Reply-To: <fa.yV32AYzot0OkvPVCY7VTCvd6rJw@ifi.uio.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:

> John wrote:
>
>> Jesse Brandeburg wrote:
>>
>>> can you try adding mdelay(100); in e100_eeprom_load before the for loop,
>>> and then change the multiple udelay(4) to mdelay(1) in e100_eeprom_read
>>
>> I applied the attached patch.
>>
>> Loading the driver now takes around one minute :-)
> 
> ouch, but yep, thats what happens when you use "super extra delay"
> 
>> I ran 'source load_unload' 25 times in a loop.
>>
>> The first 12 times were successful. The last 13 times failed.
>> (cf. attached archive)
>>
>> I noticed something very strange.
>>
>> The number of words obviously in error (0xFFFF) returned by the EEPROM
>> on 00:09.0 is not constant.
> 
> That is very strange, I would think that maybe you have something else
> on the bus with the e100 that may be hogging bus cycles you have
> failing hardware (maybe a bad eeprom, or possibly a bad mac chip)
> 
>> $ grep -c 0xFFFF insmod*
>> insmod_300.txt:0
>> insmod_301.txt:0
>> insmod_302.txt:0
>> insmod_303.txt:0
>> insmod_304.txt:0
>> insmod_305.txt:0
>> insmod_306.txt:0
>> insmod_307.txt:0
>> insmod_308.txt:0
>> insmod_309.txt:0
>> insmod_310.txt:0
>> insmod_311.txt:0
>> insmod_312.txt:1
>> insmod_313.txt:5
>> insmod_314.txt:24
>> insmod_315.txt:45
>> insmod_316.txt:243
>> insmod_317.txt:256
>> insmod_318.txt:256
>> insmod_319.txt:256
>> insmod_320.txt:256
>> insmod_321.txt:256
>> insmod_322.txt:256
>> insmod_323.txt:253
>> insmod_324.txt:240
> 
> this is even stranger, does it cycle back down (sine wave) to zero
> again?  The delays did seem to work, at least sometimes.  This
> indicates that something needs that extra delay to successfully read
> the eeprom.  I might try changing all the udelay(4) to udelay(40) (x10
> increase) and see if that gives you a happy medium of "most times
> driver loads without error"
> 
> John, this problem seems to be very specific to your hardware.  I know
> that you have put in a lot of time debugging this, but I'm not sure
> what we can do from here.  If this were a generic code problem more
> people would be reporting the issue.
> 
> What would you like to do?  At this stage I would like e100 to work
> better than it is, but I'm not sure what to do next.

Hello everyone,

I'm resurrecting this thread because it appears we'll need to support 
these motherboards for several months to come, yet Adrian Bunk has 
scheduled the removal of eepro100 in January 2007.

To recap, we have to support ~30 EBC-2000T motherboards.
http://www.adlinktech.com/PD/web/PD_detail.php?pid=213
These motherboards come with three on-board Intel 82559 NICs.

Last time I checked, i.e. two months ago, e100 did not correctly 
initialize all three NICs on these motherboards. Therefore, we've been 
using eepro100.

I will be testing the latest 2.6.20 kernel to see if the situation has 
changed, but I wanted to let you all know that there are still some 
eepro100 users out there, out of necessity.

Regards,

John
