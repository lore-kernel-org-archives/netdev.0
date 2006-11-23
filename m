From: Guennadi Liakhovetski <gl@dsa-ac.de>
Subject: softmac roaming behaviour
Date: Thu, 23 Nov 2006 13:27:25 +0100 (CET)
Message-ID: <Pine.LNX.4.63.0611231128570.1891@pcgl.dsa-ac.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dsa-ac.de ([62.112.80.99]:12045 "EHLO mail.dsa-ac.de")
	by vger.kernel.org with ESMTP id S933542AbWKWM1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Nov 2006 07:27:34 -0500
Received: from komserver.dsa-ac.de (KOMSERVER2.dsa-ac.de [172.28.1.4])
	by mail.dsa-ac.de (Maildaemon on Linux) with ESMTP id C93D5194BD
	for <netdev@vger.kernel.org>; Thu, 23 Nov 2006 13:27:30 +0100 (CET)
Received: from pcgl.dsa-ac.de (PCGL.dsa-ac.de [172.29.17.23])
	by komserver.dsa-ac.de (Postfix on Linux-Server) with ESMTP id 0508A4F51
	for <netdev@vger.kernel.org>; Thu, 23 Nov 2006 13:27:26 +0100 (CET)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

First I have to excuse myself - the questions I am going to ask here are 
based on the 2.6.18-rc2 softmac stack, so, if any of them are no longer 
relevant, please, just say "fixed since version ..." But just looking 
through the linux/kernel/git/linville/wireless-dev.git git tree didn't 
reveal any relevant commits.

We are building mobile systems with zd1211rw / softmac / ieee80211 WLAN 
stack. These are not consumer devices, rather industrial embedded systems 
working in difficult wireless environments and having the task to provide 
maximum reliable network availability. Therefore robust roaming support is 
vital for our application.

With 2.6.18-rc2 kernel + git commit 
83c15ac14de7a01633c07e1c68226c73f9c92421 from 
http://www.deine-taler.de/zd1211/zd1211.git we have following problems:

1. no automatic roaming. Lost connection to the current AP doesn't cause 
re-scan or re-association attempts.

2. on lost connection old and possibly invalid AP data is used. After each 
scan all detected access-points are added to a global list with a 
"quality" parameter. If the connection is lost and the user attempts to 
establish a new connection with the same parameters (ESSID, etc.) only the 
"best" AP is tried. If it fails, e.g., because that AP is no longer 
available, that AP will not be removed from the list, it will further base 
new association attempts purely on signal quality and further try to 
connect to the unreachable AP. I.e., if after the first "iwlist scan" you 
get AP1 with quality 5 and AP2 with quality 4, and after the second "scan" 
AP2 with quality 4 and AP3 with quality 3 (higher-better), it will only 
try to connect to AP1.

Are these problems still present in the current kernels and if so, how can 
they be fixed?

Thanks
Guennadi
---------------------------------
Guennadi Liakhovetski, Ph.D.
DSA Daten- und Systemtechnik GmbH
Pascalstr. 28
D-52076 Aachen
Germany
