From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: XFRM state hash value
Date: Tue, 10 Mar 2009 10:46:03 +0100
Message-ID: <49B636DB.7010004@dev.6wind.com>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:52269 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754442AbZCJJqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 05:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

this commit: [XFRM]: Hash xfrm_state objects by source address too. 
(http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commitdiff;h=c1969f294e624d5b642fc8e6ab9468b7c7791fa8)
introduces src address in hash for state.
But in some cases, source address is a wildcard when state is inserted. For 
example, we can have something like this:
# setkey -c
add :: ff02::9 ah 0x100 -m transport -A hmac-md5 "cle3goldorakcle3";

In this case, __xfrm_state_insert() will calculate the hash value with src 
address set to 0, but xfrm_state_find() will use the real source address to 
calculate this hash. At the end, no state will be found.
The most simple way to resolve this pb is to revert the previous patch, but 
maybe someone has a better idea...


Regards,
Nicolas
