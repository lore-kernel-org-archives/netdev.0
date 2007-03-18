From: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Subject: Re: dst_ifdown breaks infiniband?
Date: Sun, 18 Mar 2007 22:33:45 +0200
Message-ID: <20070318203345.GF11078@mellanox.co.il>
References: <20070318155532.GG7958@mellanox.co.il>
	<20070318191238.GA20518@ms2.inr.ac.ru>
Reply-To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, general@lists.openfabrics.org,
	Roland Dreier <rolandd@cisco.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:23069 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933200AbXCRUdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Mar 2007 16:33:04 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1142506uga
        for <netdev@vger.kernel.org>; Sun, 18 Mar 2007 13:33:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070318191238.GA20518@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>:
Subject: Re: dst_ifdown breaks infiniband?
> > Can dst->neighbour be changed to point to NULL instead, and the neighbour
> > released?
> 
> It should be cleared and we should be sure it will not be destroyed
> before quiescent state.
> 
> Seems, this is the only correct solution, but to do this we have
> to audit all the places where dst->neighbour is dereferenced for
> RCU safety.
> 
> Actually, it is very good you caught this eventually, the bug was
> so _disgusting_ that it was "forgotten" all the time, waiting for
> someone who will point out that the king is naked. :-)

Actually that might not be too bad:
$grep -rIi 'dst->neighbour' net/ | wc -l
36

I'll try to do it.

-- 
MST
