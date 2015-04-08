From: Xin Huang <huangxin811@gmail.com>
Subject: Multiple default router probe in Linux 3.14
Date: Thu, 9 Apr 2015 00:54:02 +0800
Message-ID: <CAGgZr_3w4wb-LGJ61iTj2ishtnno=m7jOs0o8PqwmZNwt9Bjmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:36728 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070AbbDHQyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:54:03 -0400
Received: by iebrs15 with SMTP id rs15so79538646ieb.3
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 09:54:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, guys,

I'm trying to pass IPv6 ready logo test for my project and have
question on Linux multiple default router probe implementation.
Router may have multiple default router in its list if multiple RA
received, all have same priority set.
When router send NS to 1st router but do not get NA response, it
should send NS to 2nd router to check if it's reachable. This feature
seems covered by implementation of option CONFIG_IPV6_ROUTER_PREF, but
only effect when net->ipv6.devconf_all->forwarding is disabled(that
means host mode).
But in the case that router's life time is still valid but it's
reachable expired, the default router is not removed from router table
and we are still in router mode, we should also probe second router if
first router do not respond NS, I need probe logic taking effect in
this mode(net->ipv6.devconf_all->forwarding is 1). It seems conflict
with current Linux implementation.
Can we remove 'net->ipv6.devconf_all->forwarding' check when call
rt6_check_neigh()? Or any other suggestion?

Thanks.
