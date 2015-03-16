From: "Cedric Debarge" <cedric.debarge@acksys.fr>
Subject: Operstate management
Date: Mon, 16 Mar 2015 18:07:01 +0100
Message-ID: <773DB8A82AB6A046AE0195C68612A319019FED54@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out06.msg.oleane.net ([62.161.7.4]:37089 "EHLO
	smtp-out06.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797AbbCPRt0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 13:49:26 -0400
Received: from smtp07.msg.oleane.net (smtp07.mail.priv [172.17.20.116])
	by smtp-out06.msg.oleane.net with ESMTP id t2GHRUsl006723
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 18:27:30 +0100
Received: from acksys.fr ([195.6.104.67]) (authenticated)
	by smtp07.msg.oleane.net (MTA) with ESMTP id t2GH72VV015585
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 18:07:02 +0100
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I have a problem with the Mac80211 driver and Wpa_supplicant in
operstate management.

My sta is connected to AP1 and I launch iperf from the sta to a computer
(behind the AP).
I force a handover from AP1 to AP2 and the sta sends an arp packed
during the WPA Handshake.

The tcpdump capture is given below:
17:43:12.964096 EAPOL key (3) v2, len 95
17:43:12.998439 EAPOL key (3) v1, len 117
17:43:13.062409 ARP, Request who-has 10.32.61.100 tell 10.32.0.1, length
28
17:43:13.079989 EAPOL key (3) v2, len 151
17:43:13.082764 EAPOL key (3) v1, len 95
17:43:14.062381 ARP, Request who-has 10.32.61.100 tell 10.32.0.1, length
28
17:43:14.127101 ARP, Reply 10.32.61.100 is-at b8:88:e3:45:1d:c6 (oui
Unknown), length 46
17:43:14.127123 IP 10.69.1.201.41690 > 10.32.61.100.5001: UDP, length
1470
17:43:14.127136 IP 10.69.1.201.41690 > 10.32.61.100.5001: UDP, length
1470

I checked the wireless interface state during WPA Handshake, the
Operstate during WPA Handshake is set to IF_OPER_DORMANT.

Is it normal that the local IP stack sends a frame with this operstate ?
If I've correctly understood this state, the Local IP stack should wait
the IF_OPER_UP to transfert data. Is it right?

What is the link between the operstate and link_mode?

Any help will be appreciatted.

Cedric Voncken
