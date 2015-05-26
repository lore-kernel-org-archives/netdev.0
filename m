From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tc drop stats different between bond and slave interfaces
Date: Tue, 26 May 2015 09:29:15 -0700
Message-ID: <1432657755.4060.268.camel@edumazet-glaptop2.roam.corp.google.com>
References: <616929303.117745.1432618508227.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
	 <1432620263.4060.229.camel@edumazet-glaptop2.roam.corp.google.com>
	 <167658669.119043.1432626069820.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34652 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754530AbbEZQ3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 12:29:17 -0400
Received: by igbhj9 with SMTP id hj9so64404489igb.1
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 09:29:16 -0700 (PDT)
In-Reply-To: <167658669.119043.1432626069820.JavaMail.open-xchange@oxuslxltgw05.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-26 at 03:41 -0400, jsullivan@opensourcedevel.com wrote:
> 

> Hi, Eric.  All the traffic flowing through a single class is because
> of the testing we are doing.  It all falls into the bulk class and we
> are not generating any other traffic.  The remote side utilizes some
> of the other classes because of the ACK and ESP packets.
>  
> We do want to control shaping closely so I suppose we should place it
> on the bond.  We are using HFSC.  In doing that, are we creating a
> problem that we have left the default qdiscs on the physical
> interfaces? We could redirect those into the IFB interface like we do
> the bond interface but then wouldn't we shape twice? Should we put
> fq_codel on there like we put on the end of the IFB interface? Thanks 

Please do not send HTML messages to the list. netdev does not allow
this.

Leaving default qdisc on the slave is fine. It allows proper buffering
of bursts.

I see no gain using fq_codel twice in the path. It really matters where
the bottleneck is.
