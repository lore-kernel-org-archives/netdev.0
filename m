From: Bill Shirley <bshirley@apinetstore2.apirx.biz>
Subject: Ipsec with mark encryption decision made before mangle output chain
Date: Wed, 04 Feb 2015 14:06:30 -0500
Message-ID: <54D26DB6.6000404@apinetstore2.apirx.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 98-159-192-167.scottsboro.org ([98.159.192.167]:46240 "EHLO
	smtp.apinetstore2.apirx.biz" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161186AbbBDTPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 14:15:36 -0500
Received: from [192.168.4.2] (ip-69-33-189-147.atl.megapath.net [69.33.189.147])
	by smtp.apinetstore2.apirx.biz (Postfix) with ESMTPSA id 1772B5600135
	for <netdev@vger.kernel.org>; Wed,  4 Feb 2015 13:06:08 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm setting up a pair of Ipsec tunnels (to the same destination) and using ip xfrm policy marks (no state marks).

The following doesn't work, the packet never gets incrypted:
ping 192,168.4.1

However, this works:
ping -m 80896 192.168.4.1

I have rules in my iptables -t mangle output to set the mark:
     0     0 RETURN     esp  --  *      * 0.0.0.0/0            0.0.0.0/0            mark match 0x13c00/0x3ff00 /* esp 
with a mark */
     0     0 RETURN     esp  --  *      * 0.0.0.0/0            0.0.0.0/0            mark match 0x12c00/0x3ff00 /* esp 
with a mark */
     4   336 CONNMARK  !esp  --  *      * 0.0.0.0/0            192.168.4.0/24       ctstate NEW /* -vpn- new outgoing */ 
CONNMARK xset 0x10700/0x3ff00
     4   336 MARK      !esp  --  *      * 0.0.0.0/0            0.0.0.0/0            connmark match 0x10700/0x3ff00 
match-set sfn_ctel_up dst /* -vpn- mark for encryption */ MARK xset 0x13c00/0x3ff00
     4   336 MARK      !esp  --  *      * 0.0.0.0/0            0.0.0.0/0            connmark match 0x10700/0x3ff00 
match-set sfn_pwrbd_up dst /* -vpn- mark for encryption */ MARK xset 0x12c00/0x3ff00
The numbers are from the ping without the mark.  As you can see, it does encrypt the packet (no esp matches).


Is it possible that the encryption mark is selected before the output chain?

Is this the right place to post for this type of problem?

Thanks,
Bill
