From: jamal <hadi@cyberus.ca>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Sat, 28 Nov 2009 14:44:02 -0500
Message-ID: <1259437442.3864.61.camel@bigi>
References: <db81a9a20911230443h443b3c2l8fab5aef7b09cfa@mail.gmail.com>
	 <1259137434.9191.3.camel@nienna.balabit>
	 <db81a9a20911260919w1ffded25ref5ae24ee73f8eda@mail.gmail.com>
	 <1259310417.3809.5.camel@nienna.balabit> <1259337932.3299.3.camel@bigi>
	 <20091128151515.GA20476@sch.bme.hu> <4B1145F1.3090704@trash.net>
	 <1259424278.3864.16.camel@bigi> <4B1158CE.90803@trash.net>
	 <1259429774.3864.41.camel@bigi>  <20091128190500.GB12264@sch.bme.hu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	KOVACS Krisztian <hidden@balabit.hu>,
	Andreas Schultz <aschultz@warp10.net>, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: KOVACS Krisztian <hidden@sch.bme.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f194.google.com ([209.85.221.194]:64246 "EHLO
	mail-qy0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904AbZK1Tn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 14:43:58 -0500
Received: by qyk32 with SMTP id 32so996637qyk.4
        for <netdev@vger.kernel.org>; Sat, 28 Nov 2009 11:44:04 -0800 (PST)
In-Reply-To: <20091128190500.GB12264@sch.bme.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-11-28 at 20:05 +0100, KOVACS Krisztian wrote:
> Hi,
> 

> The source address *is* unicast. 

Sorry - I meant the route type is unicast. The fact that an address is
unicast or not is already dealt with by the time you get to source
address validation (in ip_input())

> The problem is that the routing setup is
> asymmetrical, as Patrick has already mentioned: we're using a mark to
> force certain packets (those that have matching sockets on the host) being
> delivered locally.
>
> In the other direction, reply packets won't be marked by the iptables
> rules and thus will be routed on egress just fine. 

In that case i dont understand the reluctance to use unicast routes.
Maybe you can explain and put me at ease because i see youve put extra
effort to use local addresses. 

> Your modification has
> the assumption that routing is symmetrical, and that reply packets will
> have the same mark. That assumption is not necessarily right, and I think
> it's not entirely unreasonable to think that not only tproxy setups will
> be broken by the change.
> 
> > So i didnt introduce that logic thats causing this pain.
> 
> Well, it depends whether or not you consider the initial setup valid.
> 

Based on what i see - I frankly dont. If i looked up the source address
and found that it belonged to something other than unicast route - we
drop it. It doesnt matter whether you use policy routing, rpf or not.
It may be the solution is to allow local routes under certain conditions
although i dont understand why.

> > If it worked before it was hack or fluke imo ;-> If we think that
> > source address validation needs to check for something else
> > additionally, i think thats a separate topic (but doesnt
> > seem worth a change)
> 
> My only concern is that this definitely breaks current setups, and while
> we do have a workaround we don't have a way to let all users know what
> needs to be done...

This code just went in i think. And really this is a user space issue;
i am not unreasonable - please convince me i am just having a technical
challenge understanding your desire to use local instead of unicast.

cheers,
jamal

