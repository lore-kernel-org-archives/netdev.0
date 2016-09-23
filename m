From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net] ip6_gre: fix flowi6_proto value in
 ip6gre_xmit_other()
Date: Fri, 23 Sep 2016 22:00:36 +0300
Message-ID: <20160923220036.55d469b0@halley>
References: <1474649699-31069-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Lance Richardson <lrichard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33797 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760456AbcIWTAo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 15:00:44 -0400
Received: by mail-wm0-f68.google.com with SMTP id l132so4142542wmf.1
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 12:00:43 -0700 (PDT)
In-Reply-To: <1474649699-31069-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Sep 2016 12:54:59 -0400 Lance Richardson <lrichard@redhat.com> wrote:
> Similar to commit 3be07244b733 ("ip6_gre: fix flowi6_proto value in
> xmit path"), set flowi6_proto to IPPROTO_GRE for output route lookup.

Suggesting to add:

Up until now, 'ip6gre_xmit_other' has set flowi6_proto to a bogus value.
This affects output route lookup upon xmit of non ipv4/ipv6 packets on a
ip6gretap device, in cases where routing depends on flowi6_proto.

> Since the correct proto is already set in the tunnel flowi6 template via
> commit 252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
> path."), simply delete the line setting the incorrect flowi6_proto value.
> 
> Suggested-by: Jiri Benc <jbenc@redhat.com>
> Fixes: commit c12b395a4664 ("gre: Support GRE over IPv6")
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
