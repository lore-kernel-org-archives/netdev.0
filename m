From: =?UTF-8?Q?J=C3=B6rg_Pommnitz?= <j.pommnitz@gmail.com>
Subject: Some ICMP-Reply messages don't arrive in User Space in recent Kernels
Date: Tue, 13 Oct 2015 08:47:45 +0200
Message-ID: <CAEvAWuHSwA0=j_YDbowA56eCx10sJPm5KkveneSVhBQHNKY_zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:34297 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbbJMGrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2015 02:47:47 -0400
Received: by lbbck17 with SMTP id ck17so8282611lbb.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 23:47:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,
I'm moving an application from 2.6.23 (yes, it's ancient; that's why
we are moving) to 3.18LTS. The application monitors multiple network
links to the same target with ping packets. The different links are
selected either by their next hop router (Ethernet) or the network
interface (Point-to-Point links, aka cellular data).
To force different routes to the same target, the outgoing packets are
tagged with different firewall marks. Then I'm using routing rules to
select different routing tables with different routes for the same
target.
The outgoing path works perfectly fine in both, 2.6.23 and 3.18.
However, the same is not true for the incoming ICMP replies. They are
incoming; I see them with tcpdump. But some packets do not get
delivered to user space in 3.18. I'm not 100% sure, but I think this
happens if there is no "normal" route to the ping target, e.g. the
source address of the ICMP replies. This looks like some kind of
misguided ingress filtering that keeps packets out if a normal routing
lookup fails.

Am I on the right track? If so, is there a way to disable this
filtering? If not, what could cause this changed behaviour?


Thanks in adavance and kind regards
  Joerg
