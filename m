From: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Fri, 22 Sep 2006 14:11:04 +1000
Message-ID: <089101c6ddfd$20ba4320$0b00000a@bluereef.local>
References: <20060906124447.642940bd@localhost.localdomain><01cb01c6d542$88544620$5001010a@bluereef.local> <20060919133159.27165976@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.mud.yahoo.com ([68.142.200.252]:13485 "HELO
	smtp104.biz.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S932267AbWIVELA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Sep 2006 00:11:00 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unfortunately I spoke too soon.. :-(

The driver no longer appears to fail under load but still fails randomly 
with relatively light load:

Sep 22 07:04:38 localhost syslog.info -- MARK --
Sep 22 07:24:38 localhost syslog.info -- MARK --
Sep 22 07:31:52 localhost user.info kernel: NETDEV WATCHDOG: eth1: transmit 
timed out
Sep 22 07:31:52 localhost user.err kernel: sky2 eth1: tx timeout
Sep 22 07:31:52 localhost user.debug kernel: sky2 eth1: transmit ring 27 .. 
498 report=27 done=27
Sep 22 07:31:52 localhost user.info kernel: sky2 hardware hung? flushing
Sep 22 07:39:27 localhost user.info kernel: NETDEV WATCHDOG: eth1: transmit 
timed out
Sep 22 07:39:27 localhost user.err kernel: sky2 eth1: tx timeout
Sep 22 07:39:27 localhost user.debug kernel: sky2 eth1: transmit ring 498 .. 
457 report=27 done=27
Sep 22 07:39:27 localhost user.info kernel: sky2 status report lost?
Sep 22 07:40:07 localhost user.info kernel: NETDEV WATCHDOG: eth1: transmit 
timed out
Sep 22 07:40:07 localhost user.err kernel: sky2 eth1: tx timeout
Sep 22 07:40:07 localhost user.debug kernel: sky2 eth1: transmit ring 27 .. 
498 report=27 done=27
Sep 22 07:40:07 localhost user.info kernel: sky2 hardware hung? flushing

The driver version that I am using is 1.6.1 with the tx pause bug fix 
manually applied. This is compiled against 2.6.17.13 stock.

This fault (since releasing this version into production) has now occured in 
3 sites since upgrading them yesterday. The previous version of kernel that 
was being used was 2.6.12 (based on the old sk98lin driver) which didn't 
manifest any of these problems.

If there's anything I can do to help isolate this issue please let me know.

----- Original Message ----- 
From: "Stephen Hemminger" <shemminger@osdl.org>
To: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
Cc: <netdev@vger.kernel.org>
Sent: Wednesday, September 20, 2006 6:31 AM
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix


> On Mon, 11 Sep 2006 11:35:11 +1000
> "Andrew Hall" <andrew.hall@bluereefnetworks.com> wrote:
>
>> Stephen,
>>
>> After some serious testing, this patch seems to fix the lockup issue
>> completely. I manually applied these changes against the 2.6.17.13 
>> release.
>
> Any more problems? 

