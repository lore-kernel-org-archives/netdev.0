From: Joe Stringer <joe@ovn.org>
Subject: Re: Maximum MPLS labels on Linux network stack
Date: Wed, 3 May 2017 14:46:50 -0700
Message-ID: <CAPWQB7EYL62MAHVf8VaRRB0GLie9VO4uKiN6TLXzYThwQH8YWA@mail.gmail.com>
References: <149211493832787@web33j.yandex.ru> <5a408c23-d3e2-aa3e-4574-82521b2255b0@gmail.com>
 <CAPWQB7FFwBFL9h7JoJMF4FuK7JXLrHfo5yg4aHJ4iczSdNU_bg@mail.gmail.com>
 <443301493846392@web51g.yandex.ru> <CAPWQB7HrbCVLEjaR0hObPTxrDg8qyfZo-3iYLe=NVzuPTOLxCQ@mail.gmail.com>
 <454271493846945@web51g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: David Ahern <dsahern@gmail.com>, netdev <netdev@vger.kernel.org>
To: =?UTF-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay8-d.mail.gandi.net ([217.70.183.201]:59107 "EHLO
        relay8-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751491AbdECVrQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 17:47:16 -0400
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
        by relay8-d.mail.gandi.net (Postfix) with ESMTPS id 1849040496
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 23:47:14 +0200 (CEST)
Received: from mfilter2-d.gandi.net (mfilter2-d.gandi.net [217.70.178.140])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id 0697A41C08A
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 23:47:14 +0200 (CEST)
Received: from relay5-d.mail.gandi.net ([IPv6:::ffff:217.70.183.197])
        by mfilter2-d.gandi.net (mfilter2-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Vx6w8E-ZL-th for <netdev@vger.kernel.org>;
        Wed,  3 May 2017 23:47:12 +0200 (CEST)
Received: from mail-qt0-f172.google.com (mail-qt0-f172.google.com [209.85.216.172])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 6BCD741C07C
        for <netdev@vger.kernel.org>; Wed,  3 May 2017 23:47:12 +0200 (CEST)
Received: by mail-qt0-f172.google.com with SMTP id m91so2249889qte.3
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 14:47:12 -0700 (PDT)
In-Reply-To: <454271493846945@web51g.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3 May 2017 at 14:29, Алексей Болдырев
<devel-net-ne-vlezay80@yandex.ru> wrote:
> As I understand it, it's enough to just set the variable in the source
> #define FLOW_MAX_MPLS_LABELS 3
> on
> #define FLOW_MAX_MPLS_LABELS 7
> Or is there somehow still pitfalls?

You'll probably need to update the BUILD_ASSERT_DECL for the offset of
igmp_group_ip4, and for extra safety increment FLOW_WC_SEQ and inspect
each other place that has BUILD_ASSERT_DECL statements relying on that
FLOW_WC_SEQ. Changing FLOW_WC_SEQ will introduce compiler
warnings/failures so you can step through each location, take a look
if it's relevant and update the BUILD_ASSERT_DECL.

At a glance it seems like even with that bump, OVS userspace is only
detecting support for 3 labels so you might need to update something
kernel-side as well.
