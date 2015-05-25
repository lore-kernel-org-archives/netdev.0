From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Mon, 25 May 2015 15:31:04 -0700
Message-ID: <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:36230 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbbEYWbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 18:31:07 -0400
Received: by pdfh10 with SMTP id h10so76416692pdf.3
        for <netdev@vger.kernel.org>; Mon, 25 May 2015 15:31:06 -0700 (PDT)
In-Reply-To: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-05-25 at 16:05 -0400, John A. Sullivan III wrote:
> Hello, all.  One one of our connections we are doing intensive traffic
> shaping with tc.  We are using ifb interfaces for shaping ingress
> traffic and we also use ifb interfaces for egress so that we can apply
> the same set of rules to multiple interfaces (e.g., tun and eth
> interfaces operating on the same physical interface).
> 
> These are running on very powerful gateways; I have watched them
> handling 16 Gbps with CPU utilization at a handful of percent.  Yet, I
> am seeing drops on the ifb interfaces when I do a tc -s qdisc show.
> 
> Why would this be? I would expect if there was some kind of problem that
> it would manifest as drops on the physical interfaces and not the IFB
> interface.  We have played with queue lengths in both directions.  We
> are using HFSC with SFQ leaves so I would imagine this overrides the
> very short qlen on the IFB interfaces (32).  These are drops and not
> overlimits.

IFB is single threaded and a serious bottleneck.

Don't use this on egress, this destroys multiqueue capaility.

And SFQ is pretty limited (127 packets)

You might try to change your NIC to have a single queue for RX,
so that you have a single cpu feeding your IFB queue.

(ethtool -L eth0 rx 1)
