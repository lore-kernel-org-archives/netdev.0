From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Mon, 15 Sep 2014 10:03:27 +0200
Message-ID: <54169D4F.2090607@broadcom.com>
References: <52BDE9DC.5040206@msgid.tls.msk.ru> <52BE9CF9.7030305@broadcom.com> <52BEC2F6.7010505@msgid.tls.msk.ru> <52D4FC8B.6090301@msgid.tls.msk.ru> <52F925A9.1030707@msgid.tls.msk.ru> <53526124.6050407@msgid.tls.msk.ru> <53FC1789.6020407@msgid.tls.msk.ru> <53FCA001.6090404@broadcom.com> <53FCB2A3.1050605@msgid.tls.msk.ru> <53FCFE1A.3060508@broadcom.com> <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <brcm80211-dev-list@broadcom.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:25608 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451AbaIOIDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 04:03:31 -0400
In-Reply-To: <53FDF8EB.4050905@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27-08-14 17:27, Arend van Spriel wrote:
> On 08/27/14 12:02, Michael Tokarev wrote:
>> 27.08.2014 01:37, Arend van Spriel wrote:
>>> On 08/26/14 18:15, Michael Tokarev wrote:
>> []
>>> Well, sorry about that. I did see the other messages fly by and
>>> noticed you were using the wl driver so assumed you were fine with that.
>>
>> That's past already.  I had several issues with wl driver,
>> and current issue is that even the latest (Aug-2014) version
>> of wl driver doesn't work with current kernel.  So I can't
>> really even compare wl and brcmsmac, -- in kernels<  3.16
>> brcmsmac does not work, but wl can't be compiled for 3.16,
>> and using different kernels for comparison is a bit wrong
>> because there may be differences in other areas.
>>
>>>     Admittedly the brcmsmac got very little attention as all our
>>> resources were put on brcmfmac.
>>
>> That happens. :)
>>
>> []
>>> Ok. Let's put frustration aside and make an effort. So could you make
>>> a trace using trace-cmd utility. The log can get quite big. The
>>> brcmsmac driver needs to be built with CONFIG_BRCM_TRACING enabled.
>>> Please execute the following commands (assuming you use ubuntu with
>>> network-manager):
>>>
>>> $ sudo stop network-manager
>>> $ sudo insmod brcmfmac.ko
>>> $ sudo trace-cmd record -e brcmsmac:*
>>>
>>> In another terminal:
>>>
>>> $ sudo start network-manager
>>>
>>> The trace-cmd must be stopped using ctrl-c.
>>
>> Okay.  This turned out to be not so simple.
>>
>> My initial attempt indicated that brcmsmac in 3.16 does
>> not work at all.  This isn't actually true - subsequent
>> attempts shows that it works.  I was ready to conclude
>> the problem is fixed (after transferring several gigs
>> of data over wifi, with tracing enabled or disabled,
>> after fresh boot or after reboot from wl-enabled kernel,
>> etc - it all worked.
>>
>> Until I hit the same stall as I described initially, the
>> same which happened numerous times with kernel 3.12 ($subj).
>>
>> After several mins of transferring it stalled.  But this
>> time (unlike with 3.12), it continued after about 30 secs.
> 
> A kernel log (so no trace) of stalling interface might be useful so if
> you can provide that and put a marker in there where you believe it
> stalled that would be great.

Hi Michael,

Did you have any opportunity to create a log file. Got a question from
someone else who got bad bcm4313 behaviour after a certain upgrade. Did
you have the same experience?

Regards,
Arend

>> So, while my initial test of 3.16 indicated the prob is still
>> here, at the same (or even worse) state, I can't really
>> reproduce it, at least in a reliable way.  There's something
>> wrong still, but at least current version is significantly
>> more useful than before (in a hope it wont stall at the
>> very wrong moment exactly ;).
>>
>> There's one more difference between brcmsmac and wl -- with
>> wl, I see significantly better speed, -- it is about 5MB/sec,
>> while with brcmsmac it jumps between 2.0..4.5MB/sec (with
>> 58..65Mbps connection rate in both cases).  Here's a typical
>> iwconfig output for brcmsmac version:
>>
>> wlan0     IEEE 802.11bgn  ESSID:"mjt"
>>            Mode:Managed  Frequency:2.412 GHz  Access Point:
>> 64:70:02:29:D9:30
>>            Bit Rate=65 Mb/s   Tx-Power=19 dBm
>>            Retry short limit:7   RTS thr:off   Fragment thr:off
>>            Power Management:off
>>            Link Quality=58/70  Signal level=-61 dBm
>>            Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
>>            Tx excessive retries:56355  Invalid misc:472   Missed beacon:0
>>
>> I'll keep trying/testing various cases, in attempt to
>> understand what's going on.  For now, I can't provide the
>> requested traces (it wont be very useful, I guess).
>>
>> BTW, are there other things not implemented in brcmsmac?
>> I see the module reminds about power management, what
>> does it mean?  Anything else missing?
> 
> Well, the wireless twiki has that info [1]. Regarding features the
> important ones that I know are still not there are 40MHz support, and
> power-save. The bcm4313 does not support 40MHz. Community contributions
> added ibss, and ap mode. For P2P and TDLS probably some changes would be
> needed although most of the legwork is done in mac80211.
> 
> Regards,
> Arend
> 
> [1]
> http://wireless.kernel.org/en/users/Drivers/brcm80211#To_be_done_for_softmac_driver
> 
> 
>> Thank you!
>>
>> /mjt
> 
