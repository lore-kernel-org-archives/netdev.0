From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v6 04/11] net: Export xmit_recursion
Date: Mon, 21 Jul 2014 08:52:38 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17279E9B@AcuExch.aculab.com>
References: <1405923435-1971-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Pravin B Shelar' <pshelar@nicira.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45846 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753493AbaGUIxz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 04:53:55 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 11593-08 for <netdev@vger.kernel.org>;
 Mon, 21 Jul 2014 09:53:45 +0100 (BST)
In-Reply-To: <1405923435-1971-1-git-send-email-pshelar@nicira.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar
> Next patch adds re-circulation action to OVS. This is recursive
> action needs to be limited to safe number recursions to
> avoid overflowing kernel stack space.  This patch export
> xmit_recursion so that OVS can increment and check the value
> before executing recirc action.
...
> +#define NET_RECURSION_LIMIT 10

I'm not entirely sure that any amount of recursion is a good idea
inside the kernel.
If the nested call frame is small enough so that your 10 nestings
are valid it must also be reasonably easy to arrange for the code
to be converted to a loop.

Remember that the highest stack use is likely to be inside some
error path (probably inside printk) so any experiments that seem
to imply that that stack use is ok are doomed.
Static analysis is possible (indirect calls make it tricky) provided
there is no recursion.
I did some static stack use analysis for an embedded system many
years ago. It showed that we needed much larger stacks that we'd
allowed for.

	David
