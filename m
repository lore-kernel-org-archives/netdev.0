From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/2] macvtap: Let TUNSETOFFLOAD actually
 controll offload features.
Date: Wed, 19 Jun 2013 09:34:50 -0700
Message-ID: <1371659690.3252.335.camel@edumazet-glaptop>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com>
	   <1371653272-11703-2-git-send-email-vyasevic@redhat.com>
	  <1371655038.3252.312.camel@edumazet-glaptop> <51C1CDBC.4040003@redhat.com>
	 <1371656769.3252.320.camel@edumazet-glaptop> <51C1DA58.4010204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, mst@redhat.com,
	jasowang@redhat.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:42616 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757027Ab3FSQe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 12:34:56 -0400
Received: by mail-ea0-f171.google.com with SMTP id m14so3380207eaj.2
        for <netdev@vger.kernel.org>; Wed, 19 Jun 2013 09:34:55 -0700 (PDT)
In-Reply-To: <51C1DA58.4010204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-19 at 12:20 -0400, Vlad Yasevich wrote:

> That's the issue.  RTNL is not owned in the ioctl case.

So it was clearly wrong. The fix was simply to get RTNL in ioctl.

Unfortunately this was not spotted earlier, this is not a reason to add
more kludge.

RTNL is the only mutex needed for the write path.

A management path using RCU_BH and RTNL and a spinlock is wrong.
