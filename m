From: patric <pakar@imperialnet.org>
Subject: Re: tg3 issues
Date: Tue, 24 Jul 2007 09:33:02 +0200
Message-ID: <46A5AB2E.4070401@imperialnet.org>
References: <469E78A2.80904@imperialnet.org> <366312910707190419se33ddd2o3870b5684e077276@mail.gmail.com> <20070719113755.GA1934@hmsreliant.homelinux.net> <469F6601.20800@imperialnet.org> <1184866465.10854.45.camel@dell> <46A0E9D7.7020904@imperialnet.org> <1184960061.4850.9.camel@dell> <46A113BA.7050805@imperialnet.org> <46A342DC.1030305@imperialnet.org> <1185226496.7922.33.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, mcarlson@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailfront-6.lil-sth.crystone.net ([83.168.207.14]:37996 "HELO
	mailfront-6.lil-sth.se.crystone.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1759346AbXGXHdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 03:33:12 -0400
In-Reply-To: <1185226496.7922.33.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:

>> Last update on this.
>>
>> "udelay( 100 + net_random % 300 )" seems to work much better and i have 
>> not had a single problem getting the link up within 10 seconds of a cold 
>> or warm-boot, and most often the link comes up directly without any sort 
>> of delay instead like before when it could hang for 30 seconds before 
>> getting a link, if you even got a link.
>>
>>     
>
> We'll have to do some testing to see if we can find a better solution.
> Adding up to 400 usec of busy wait is not ideal.  Are you connecting two
> 5701 fiber cards directly to each other in your setup?
>
>
>   

Hi,

Yea, it's and ugly hack, but it's a workaround that at least works for me.
Have done some additional tests and to me it seems that the driver just 
needs to wait a bit longer to detect the link + some random time to get 
around the issues it might have when chasing the other systems state.
Don't have the numbers in front of me, but i did some tests to get the 
'optimum' delay to wait and it seems like the larger the wait time (even 
up to around 40-50ms!) causes the autoneg to go much smoother and 
faster. And remember that the link can be reported up, but no traffic 
can be passed via the link before the autoneg is complete and both cards 
reports back that flowcontrol is enabled so you need to verify the link 
by trying to send some data and not just look at the link-status.

Hope my conclusions might help, or atleast point you in the right direction.

I have 2
01:08.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 
Gigabit Ethernet (rev 15)   ( 14e4:1645 )
connected via a single FC cable.
And the two systems are one single-core and one dual-core AMD system.

Regards,
Patric

