From: Cong Wang <cwang@twopensource.com>
Subject: Re: suspicious RCU usage in net/ipv4/ip_tunnel.c:80
Date: Thu, 16 Jan 2014 16:26:15 -0800
Message-ID: <CAHA+R7N358TZyY9DGZbEQFV5aC08+ZYEaxJKOGPDDN58V4FQ=Q@mail.gmail.com>
References: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
	<1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7OMM9ndy4hXF4rJBsA_Rb0KZ-MonuvE++wgzO_oMbo+eQ@mail.gmail.com>
	<1389548697.31367.184.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7Pe_pGFw5cA3v_RnGvOurAykJNVH5=DeeEVHG84faWi2Q@mail.gmail.com>
	<1389601233.31367.213.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140114045316.GV10038@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:47580 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbaAQA0R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:26:17 -0500
Received: by mail-la0-f53.google.com with SMTP id e16so3147118lan.12
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 16:26:15 -0800 (PST)
In-Reply-To: <20140114045316.GV10038@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 8:53 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> OK, I'll bite...  This code invokes dst_release() which looks to me
> like it dereferences this pointer:
>

Yeah, sure, my point is it doesn't dereference the pointer when it holds
the spin_lock. I read rcu_dereference_protected() as "deference the rcu
pointer when we protected by ...", but we dereference it after the lock is
released. :)


@Eric, will you submit your patch as a formal one? I already tested it.

Thanks.
