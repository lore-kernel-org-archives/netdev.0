From: vaughan <vaughan.cao@oracle.com>
Subject: How to assign sockaddr_nl->nl_groups when using connector
Date: Tue, 19 Mar 2013 10:15:43 +0800
Message-ID: <5147CA4F.5050801@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, KY Srinivasan <kys@microsoft.com>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40175 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754844Ab3CSCOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 22:14:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

I am not quite sure how to assign nl_groups when using connector. You
Documentation/connector/connector.txt don't explain it very clearly. I
thought it's a bitmask representing only 32 groups.
If I just want to subscribe only one group such as CN_KVP_IDX, what
shall I do? Which one below is correct?
a) l_local.nl_groups = CN_KVP_IDX;
Or
b) l_local.nl_groups = 1 << (CN_KVP_IDX -1)
and bind with bind(s, (struct sockaddr *)&l_local, sizeof(struct
sockaddr_nl)).
I ran your example in Documentation/connector/. 'l_local.nl_groups = -1'
in ucon.c seems subscribe all channels, because if I start cgred
service, ucon will receive messages with idx=1.

And it seems setsockopt is not needed now, for it is done by
netlink_autobind? You even comment it out using '#if 0' in
Documentation/connector/ucon.c.

Could you do me a favor to check
http://driverdev.linuxdriverproject.org/pipermail/devel/2013-March/036306.html
to see if my understanding is correct or not? Thanks.

-- 
Regards,
Vaughan
