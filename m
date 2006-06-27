From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 09:34:04 -0500
Message-ID: <44A141DC.3080401@lwfinger.net>
References: <20060626212547.GE30706@tuxdriver.com> <44A09289.4040200@garzik.org> <44A097AA.6080809@lwfinger.net> <200606271530.06749.mb@bu3sch.de> <44A13C81.2050503@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, bcm43xx-dev@lists.berlios.de,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:64717 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1161069AbWF0OeU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 10:34:20 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44A13C81.2050503@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Michael Buesch wrote:
>>
>> Short: Don't touch it. Fullstop.
>>
>> Long: The delay will _never_ be exhausted. Actually the for-counter
>> is only there to not lock up the machine, if there is a Bug in the
>> driver. (__much__ easier debugging).
>> The loop will only iterate a few times, typically.
>> Actually, _if_ we want to change something, we should do this:
>>
>> for (i = 1000000; i; i--) {
>>     ...
>>     udelay(1);
>> }
>>
>> (max loop multiplied by 10, delay value divided by 10).
>> This will shorten the whole delay by a few usecs (up to 10).
>> I will send a patch for this, if it is desired.
>>
>> But lowering the loop counter value is NACKed by me,
>> because it simply does not make sense.
> 
> 
> My overriding concern was that this type of loop spins the CPU at 100% 
> until the hardware condition is satisfied, which starves all other 
> kernel work on that CPU, and is very unfriendly to power consumption 
> (though I believe monitor/mwait/cpu_relax helps on x86).
> 
> Overall, bcm43xx is _really really bad_ about this sort of thing.  Just 
> grepping for udelay in bcm43xx_radio.c shows some of the worst 
> offenders.  bcm43xx_radio_init2060() and bcm43xx_radio_selectchannel() 
> both look like candidates for using msleep() rather than udelay().

It is not my place to get into the middle of this discussion; however, my interface has been pinging 
my AP for over 12 hours with the loop counter starting at 1000. I get the usual log entries for the 
hourly TKIP changes, but no MAC suspend failures.

Larry

