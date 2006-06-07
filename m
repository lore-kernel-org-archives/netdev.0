From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 10:47:31 -0500
Message-ID: <4486F513.5050906@lwfinger.net>
References: <4485D66B.7080108@lwfinger.net> <1149682213.3999.14.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:1929 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S932270AbWFGPrg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 11:47:36 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1149682213.3999.14.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> 
> generic IE is what the wext is called, it is the IE that wpa_supplicant
> sets. Not sure what's going on though, I know next to nothing about wpa.

I have a little more information on what is happening. In IEEE Std 802.11i-2004, which defines the 
WPA protocol, Figure 11a shows the sequence of exchanges needed to associate. Both bcm43xx-softmac 
and ndiswrapper go through the "Open System Authentication" process. Where they seem to diverge is 
in the STA's "Association Request (Security Parameters)" step. With ndiswrapper, the AP responds 
with a WPA EAPOL-Key message; whereas with softmac, the AP sends back the "invalid pairwise cipher 
message" and rejects the association.

Can anyone point to a reference that states what the content of the Association Request should be to 
get the AP to respond with the EAPOL-Key message? Unfortunately, I have no possibility of 
implementing a sniffer to see what a "correct" message contains.

Larry
