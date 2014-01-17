From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: suspicious RCU usage in net/ipv4/ip_tunnel.c:80
Date: Thu, 16 Jan 2014 16:49:44 -0800
Message-ID: <1389919784.31367.442.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHA+R7PAyR_cJ9_9nfUBc0U9o-U=gCV+sN_VYbHwgq-QdoEVzQ@mail.gmail.com>
	 <1389403281.31367.171.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7OMM9ndy4hXF4rJBsA_Rb0KZ-MonuvE++wgzO_oMbo+eQ@mail.gmail.com>
	 <1389548697.31367.184.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7Pe_pGFw5cA3v_RnGvOurAykJNVH5=DeeEVHG84faWi2Q@mail.gmail.com>
	 <1389601233.31367.213.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140114045316.GV10038@linux.vnet.ibm.com>
	 <CAHA+R7N358TZyY9DGZbEQFV5aC08+ZYEaxJKOGPDDN58V4FQ=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Tom Herbert <therbert@google.com>,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:62995 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbaAQAtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:49:53 -0500
Received: by mail-gg0-f174.google.com with SMTP id g10so1108465gga.5
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 16:49:53 -0800 (PST)
In-Reply-To: <CAHA+R7N358TZyY9DGZbEQFV5aC08+ZYEaxJKOGPDDN58V4FQ=Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-16 at 16:26 -0800, Cong Wang wrote:
> On Mon, Jan 13, 2014 at 8:53 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > OK, I'll bite...  This code invokes dst_release() which looks to me
> > like it dereferences this pointer:
> >
> 
> Yeah, sure, my point is it doesn't dereference the pointer when it holds
> the spin_lock. I read rcu_dereference_protected() as "deference the rcu
> pointer when we protected by ...", but we dereference it after the lock is
> released. :)

See rcu_dereference_protected() as rcu_fetch_protected()

We read/fetch the pointer, but wont dereference the memory pointer by
this pointer later.

> 
> 
> @Eric, will you submit your patch as a formal one? I already tested it.

I actually sent another patch : 

http://patchwork.ozlabs.org/patch/311902/

Thanks !
