From: Daniel Drake <dsd@gentoo.org>
Subject: SIOCGIWSCAN wireless event behaviour
Date: Thu, 20 Apr 2006 15:15:59 +0100
Message-ID: <4447979F.4050603@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: softmac-dev@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:53102 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750751AbWDTOCK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 10:02:10 -0400
To: jt@hpl.hp.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jean,

A query regarding wireless events: under which circumstances should a 
driver/stack send a SIOCGIWSCAN event to userspace?

Should it be sent whenever a driver has new scan results available, or 
only when the user requested a scan a short time beforehand (via 
SIOCSIWSCAN)?

I ask this because softmac is sending the SIOCGIWSCAN event even when 
the user did not explicitly ask for it.

For example, the user sets an essid. softmac starts a scan in order to 
find the requested network. The network is found, the scan completes, 
and softmac sends SIOCGIWSCAN. softmac then authenticates to that 
network, associates, and then sends SIOCGIWAP.

I think the 'extra' SIOCGIWSCAN event may be confusing wpa_supplicant 
(but have not confirmed that yet).

Thanks,
Daniel
