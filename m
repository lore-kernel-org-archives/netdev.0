From: Vincent Li <vincent.mc.li@gmail.com>
Subject: ip_no_pmtu_disc and UDP
Date: Fri, 23 Oct 2015 09:45:47 -0700
Message-ID: <CAK3+h2wFfh+HE78kHoWwgc9vyTCLWM90C4RQ=uTRk8551-jQ7A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:35554 "EHLO
	mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbbJWQps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 12:45:48 -0400
Received: by lfbn126 with SMTP id n126so55547480lfb.2
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 09:45:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It looks ip_no_pmtu_disc setting does not affect UDP IP packet DF bit
setting, is that intended behavior? echo 0, 1, 2, 3 respectively to
ip_no_pmtu_disc, UDP IP packet always have DF bit cleared, unless use
IP_PMTUDISC_DO on IP_MTU_DISCOVER as ip man page says.

in inet_create, seems to prove that.

       if (net->ipv4.sysctl_ip_no_pmtu_disc)
                inet->pmtudisc = IP_PMTUDISC_DONT;
        else
                inet->pmtudisc = IP_PMTUDISC_WANT;

so I am wondering why UDP is excluded by ip_no_pmtu_disc, why in
inet_create, not assign each individual ip_no_pmtu_disc setting to
inet->pmtudisc but only check true and assign IP_PMTUDISC_DONT or
IP_PMTUDISC_WANT only.

Thanks

Vincent
