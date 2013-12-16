From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next v2 0/6] slight optimization of addr compare for
 some modules
Date: Mon, 16 Dec 2013 09:25:48 -0800
Message-ID: <1387214748.18217.52.camel@joe-AO722>
References: <52AEB8B3.5010405@huawei.com>
	 <1387205111.18217.7.camel@joe-AO722> <52AF13F4.5040409@gmail.com>
	 <1387207006.18217.28.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0060.hostedemail.com ([216.40.44.60]:53666 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754564Ab3LPRZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 12:25:51 -0500
In-Reply-To: <1387207006.18217.28.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi again Ding.

These should still be inspected for appropriate use of
ether_addr_equal or ether_addr_equal_unaligned, but a
better cocci input sp-file is:

$ cat ether_addr_equal_unaligned.cocci 
@@
expression e1;
expression e2;
@@

-	!memcmp(e1, e2, \(6\|ETH_ALEN\))
+	ether_addr_equal_unaligned(e1, e2)

@@
expression e1;
expression e2;
@@

-	memcmp(e1, e2, \(6\|ETH_ALEN\)) == 0
+	ether_addr_equal_unaligned(e1, e2)

@@
expression e1;
expression e2;
@@

-	memcmp(e1, e2, \(6\|ETH_ALEN\))
+	!ether_addr_equal_unaligned(e1, e2)

@@
expression e1;
expression e2;
@@

-	memcmp(e1, e2, \(6\|ETH_ALEN\)) != 0
+	!ether_addr_equal_unaligned(e1, e2)
