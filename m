From: "seventh guardian" <seventhguardian@gmail.com>
Subject: Re: d80211 deadlock with wpa_supplicant and rmmod
Date: Thu, 12 Jul 2007 00:17:35 +0100
Message-ID: <1caff7430707111617o70a534a5x2cf6b611a91f301a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:23497 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934786AbXGKXRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 19:17:37 -0400
Received: by ug-out-1314.google.com with SMTP id j3so225132ugf
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 16:17:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
First of all I'm fairly new to this list (in all, this is my first
message), so please be gentle.. I promise I will try not to waste your
precious time.

> I believe we have a deadlock in d80211.

I have it too. But I'm using iwl3945 driver, in-kernel mac80211, and a
gentoo kernel (basically a patched vanilla-2.6.22.1). My machine is a
x86_64 core 2 duo.

> The following triggers it on my 2way SMT machine with preempt.
>
> modprobe bcm43xx-d80211
> add sta0
> ifconfig sta0 up
> start wpa_supplicant on the interface
> rmmod bcm43xx-d80211
>
> After that rmmod hangs spinning and wpa_supplicant
> stays in D state.
>
> If I first kill wpa_supplicant and then rmmod the module,
> it does not deadlock.

I can trigger this way:

modprobe iwl3945
ifconfig wlan0 up
start wpa_supplicant
do some wpa_supplicant work (for instance issue a scan)
stop wpa_supplicant

Then it will deadlock (that is, wpa_supplicant will refuse to be
killed). The same thing happens if I try to modprobe the module out
(modprobe will "hang spinning" as you said). I have to ultimately
hard-shutdown my machine to bring it back to normal.

> Below is sysrq-t output. It looks like it's related to rtnl_mutex.
>
> (...)

I'm sorry for my inexperience, but I have no idea on which more data
to provide you. I will gladly help running any tests you would find
appropriate.

> --
> Greetings Michael.

Cheers,
  Renato Caldas
