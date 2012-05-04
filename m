From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Fri, 04 May 2012 09:47:49 +0200
Message-ID: <1336117669.3752.49.camel@edumazet-glaptop>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
	 <4FA35A3D.8000205@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43215 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752674Ab2EDHrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 03:47:55 -0400
Received: by bkcji2 with SMTP id ji2so1972385bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 00:47:54 -0700 (PDT)
In-Reply-To: <4FA35A3D.8000205@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-04 at 12:25 +0800, Deng-Cheng Zhu wrote:
> On 05/04/2012 11:22 AM, Tom Herbert wrote:
> >> +struct cpu_flow {
> >> +       struct net_device *dev;
> >> +       u32 rxhash;
> >> +       unsigned long ts;
> >> +};
> >
> > This seems like overkill, we already have the rps_flow_table and this
> > used in accelerated RFS so the device can also take advantage of
> > steering.
> 
> I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
> patch) are different: The former works along with rps_sock_flow_table
> whose CPU info is based on recvmsg by the application. But for the tests
> like what I did, there's no application involved.
> 
> 
> Deng-Cheng

I really suggest you speak with MIPS arch maintainers about these IRQ
being all serviced by CPU0.

Adding tweaks in network stack to lower the impact of this huge problem
is a no go.
