From: David Miller <davem@redhat.com>
Subject: Re: [PATCH v2 net-next] af_unix: dont send SCM_CREDENTIALS by
 default
Date: Wed, 28 Sep 2011 13:30:39 -0400 (EDT)
Message-ID: <20110928.133039.889094831443618032.davem@redhat.com>
References: <1316406528.2521.15.camel@edumazet-laptop>
	<1316444524.2539.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tim.c.chen@linux.intel.com, zheng.z.yan@intel.com,
	yanzheng@21cn.com, netdev@vger.kernel.org, sfr@canb.auug.org.au,
	jirislaby@gmail.com, sedat.dilek@gmail.com, alex.shi@intel.com,
	Valdis.Kletnieks@vt.edu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754299Ab1I1Raw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 13:30:52 -0400
In-Reply-To: <1316447547.2539.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 19 Sep 2011 17:52:27 +0200

> This patch includes SCM_CREDENTIALS information in a af_unix message/skb
> only if requested by the sender, [man 7 unix for details how to include
> ancillary data using sendmsg() system call]
> 
> Note: This might break buggy applications that expected SCM_CREDENTIAL
> from an unaware write() system call, and receiver not using SO_PASSCRED
> socket option.
> 
> If SOCK_PASSCRED is set on source or destination socket, we still
> include credentials for mere write() syscalls.

I thought a lot about this and I think we should be able to get away
with this trick, so I've added this patch to net-next, thanks!
