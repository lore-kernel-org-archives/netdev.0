From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net-timestamp: Make the clone operation stand-alone
 from phy timestamping
Date: Wed, 03 Sep 2014 15:05:08 -0700
Message-ID: <1409781908.26422.55.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com>
	 <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com>
	 <1409778438.26422.54.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:47493 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756762AbaICWFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 18:05:11 -0400
Received: by mail-pd0-f182.google.com with SMTP id fp1so11974323pdb.13
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 15:05:11 -0700 (PDT)
In-Reply-To: <1409778438.26422.54.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 14:07 -0700, Eric Dumazet wrote:

> 
> Normally, if one skb holds a reference to a socket, it should have
> skb->destructor set to a cleanup function.
> 
> Otherwise, we rely on callers following a convention, to release sk
> reference.
> 
> If you believe its needed, it should be dully documented.


BTW, skb_orphan() would BUG() on this case (skb->destrutor == NULL and
skb->sk != NULL)
