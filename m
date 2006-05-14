From: Daniel Drake <dsd@gentoo.org>
Subject: SIOCSIWESSID + SIOCSIWAP behaviour
Date: Mon, 15 May 2006 00:29:11 +0100
Message-ID: <4467BD47.5040000@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:44424 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751385AbWENXL4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 19:11:56 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jean,

I'd just like to check my understanding (and softmacs implementation) 
of SIWESSID and SIWAP behaviour, for managed mode.

When SIWESSID happens, softmac drops association/authentication with the 
current network and then starts a scan for the requested SSID. When 
found, softmac authenticates and associates to that network.

When SIWAP happens, softmac drops association/authentication with the 
current network and then starts a scan for the requested BSSID. When 
found, softmac authenticates and associates to that network.

Is it correct that both of these immediately trigger 
deauthenication+deassocation then authentication+assocation?

Is it correct that SIWAP can legally select *any* AP? (As opposed to 
only being for selecting a specific AP *on the ESS* indicated by a past 
or future SIWESSID call)


Right now, wpa_supplicant does SIWESSID and SIWAP in quick succession, 
which causes softmac to associate twice, and that quickly confuses things.

No matter how I think of it, this strikes me as a hard interface to 
implement. Because association isn't an atomic operation, it is tricky 
to get the sequencing right, e.g. if the user does SIWESSID to start 
association, and then SIWAP to select a different AP before the original 
association has completed.

Any clarification appreciated.

Thanks,
Daniel
