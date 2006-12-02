From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.19: very low transmit speed after suspend/resume with Sky2
Date: Sat, 02 Dec 2006 13:16:28 -0800
Message-ID: <4571ED2C.6040005@osdl.org>
References: <20061202091626.GA20734@thinkpad.home.local> <20061202131833.GA3673@thinkpad.home.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:37302 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1162483AbWLBVQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Dec 2006 16:16:36 -0500
To: Tino Keitel <tino.keitel@tikei.de>
In-Reply-To: <20061202131833.GA3673@thinkpad.home.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tino Keitel wrote:
> On Sat, Dec 02, 2006 at 10:16:28 +0100, Tino Keitel wrote:
>   
>> Hi folks,                                            
>>                                                      
>> since 2.6.19 I have the problem that I get lousy transmit speeds of < 1 
>> mbit/s.
>>
>> Here is a quick test, the 5th column is the transfer speed in mbit/s:
>>
>> From the affected machine to my laptop over WLAN (the affected machine
>> is connected to a Fast Ethernet switch):
>>
>> $ nttcp -r -l 1400 -n 500 dose
>> l   700000    8.16   0.04    0.6867    155.5469   824  101.04   22887.6     
>> 1   700000    8.15   0.00    0.6873 560000.0000   500  61.37    50000000.0    
>>
>> Only 0,68 mbit/s during transmit. :-(
>>
>> From my laptop to the affected machine:
>>
>> $ nttcp -l 1400 -n 5000 dose
>> l  7000000    2.21   0.03   25.3427   1999.8572  5000  2262.74  178558.7     
>> 1  7000000    2.25   0.07   24.8363    823.4810  9268  4110.41  136286.1 
>>
>> This is ok, 25 mbit/s during receive, limited by the WLAN in the
>> laptop.
>>
>> After reboot:
>>
>> $ nttcp -l 1400 -n 5000 dose
>> l  7000000    2.04   0.03   27.5005   1749.8906  5000  2455.40  156240.2
>> 1  7000000    2.08   0.06   26.9843    999.9464  9455  4556.00  168830.2
>>
>> Now I got 27 mbit/s during receive, that's ok for WLAN.
>>     
>
> Sorry, I should give the number for _transmit_ here. This was ok, too.
>
> Regards,
> Tino

Most likely, the problem is similar to one I am working. The 
device_resume code gets run before
BIOS. And the BIOS wakeup screws up the device. The proper fix will 
happen in 2.6.20.
If you are using MSI, turn that off.
