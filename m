From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 23 Sep 2014 18:25:02 +0400
Message-ID: <542182BE.2000606@msgid.tls.msk.ru>
References: <53FC1789.6020407@msgid.tls.msk.ru> <53FCA001.6090404@broadcom.com> <53FCB2A3.1050605@msgid.tls.msk.ru> <53FCFE1A.3060508@broadcom.com> <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brcm80211-dev-list@broadcom.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>,
	Seth Forshee <seth.forshee@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([86.62.121.231]:56443 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbaIWOZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 10:25:05 -0400
In-Reply-To: <54217AA5.2060803@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

23.09.2014 17:50, Arend van Spriel wrote:
> On 09/23/14 15:44, Seth Forshee wrote:
[]
>> Well, there are a few different trace events defined for brcmsmac. This
>> would enable the full set:
>>
>>   $ trace-cmd record -e brcmsmac -e brcmsmac_tx -e brcmsmac_msg
>>
>> It's been quite some time since I used them, but I think brcmsmac_tx is
>> quite noisy so you may only want to enable that if you already suspect a
>> tx problem. I always find it useful to enable the mac80211 and
>> mac80211_msg events too when debugging wireless, and I often enable
>> cfg80211 events as well (none of these are especially verbose).
> 
> Ah, I read back the email from Sep 21 and it says:
> 
> trace-cmd record brcmsmac:* &
> 
> I am surprised the capture contains something as -e is missing. Good to know there are different tracers for the driver.
> 
>> Of course all of this depends on having the right config options
>> selected. Looks like the relevant options are CONFIG_BRCM_TRACING and
>> CONFIG_MAC80211_MESSAGE_TRACING.

So, what should I enable?  I guess there's a suspection of tx path
problem (since according to tcpdump, the other side sends packets
our way, but our side does not receive them), so -e brcmsmac_tx
shold be okay to enable (and should be easy to filter out if
needed, too, I guess).  And using -e, now too, like this:

 trace-cmd record -e brcmsmac -e brcmsmac_tx -e brcmsmac_msg -e mac80211 -e mac80211 -e cfg80211

http://www.corpit.ru/mjt/tmp/brcmsmac-4313-trace-201409232.dat.gz is
the result from the following:

 modprobe brcmsmac (networkmanager is running)
 trace-cmd as above &
 wget http://ip-add-ress/random-file -O /dev/null

I waited for wget to stall (it d'loaded 240Kb) and hit
Ctrl+C.

The trace file isn't really that huge.

Thank you!

/mjt
