From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Mon, 03 May 2010 16:34:17 -0400
Message-ID: <1272918857.3926.30.camel@bigi>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>
	 <4BDB3F07.2030900@free.fr> <87bpd0zl9l.fsf@caffeine.danplanet.com>
	 <1272673614.14499.10.camel@bigi>  <87y6g1xe0h.fsf@caffeine.danplanet.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, containers@lists.osdl.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:55117 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab0ECUeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:34:22 -0400
Received: by pzk42 with SMTP id 42so358561pzk.4
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 13:34:21 -0700 (PDT)
In-Reply-To: <87y6g1xe0h.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-05-03 at 07:21 -0700, Dan Smith wrote:

> The benefits of doing what we can in userspace are well-understood and
> arguing for doing so where it makes sense is, of course, a good idea.
> 
> However, it seems to me that the rtnl interface provides us a
> reasonable layer of isolation between us and such changes.  Am I
> wrong?  

I may not have made my point earlier:
Let me give you an example by looking at your migration attributes..

-----
+            __be32 inet4_len;          /* mask length (bits)*/
+            __u32  inet4_met;          /* metric            */
+            __be32 inet4_dst;          /* route address     */
+            __be32 inet4_gwy;          /* gateway address   */
-----

At some point i had a discussion with some folks on netdev where it
seemed valueable to add a fwmark to the route. If such is made, I dont
see what the motivation for whoever is codifying to add it to your
attributes so you can migrate the fwmark. One good motivation is to make
sure the main route code fails to compile if your attributes dont get
modified - this could happen if you re-use the same data structures as
the kernel etc.

> The rtnl messages appear to be rather generic and timeless,
> and in most cases have a significant amount of flexibility with
> respect to allowing advanced attributes to be ignored (which implies
> taking the default).

True - but you still need to worry about compat issues etc i.e when you
migrate to a remote kernel they better have the same features and kernel
config.. I am assuming this is not hard to impose on an admin.
Doing things in user space allows for doing more interesting things like
negotiating on capabilities etc

> In many other areas of C/R we're not so lucky and don't have a
> well-defined interface for dumping that information out of the
> kernel...

Maybe the answer is to start by formalizing that, not sure.

cheers,
jamal

