From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 1/3 v3] net: track link-status of ipv4 nexthops
Date: Wed, 10 Jun 2015 23:07:28 -0700
Message-ID: <CAE4R7bAnPDA_S=tjaM-qLbb4ZM0_FcTPQH6jC7_Mgmc==1c6wA@mail.gmail.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com> <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:33349 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbFKGHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:07:49 -0400
Received: by qgfa66 with SMTP id a66so22436258qgf.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 23:07:49 -0700 (PDT)
In-Reply-To: <1433990233-958-2-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:
> Add a fib flag called RTNH_F_LINKDOWN to any ipv4 nexthops that are
> reachable via an interface where carrier is off.  No action is taken,
> but additional flags are passed to userspace to indicate carrier status.

Andy, it seems now RTNH_F_LINKDOWN and RTNH_F_DEAD are very similar
and I'm wondering if this could be done without introducing a new flag
and just use RTNH_F_DEAD.  The link change event would set RTNH_F_DEAD
on nh on dev link down, and clear on link up.  The sysctl knob would
be something like "nexthop_dead_on_linkdown", default off.  So
basically expanding the ways RTNH_F_DEAD can be set.  That would
simplify the patch set quite a bit and require no changes to iproute2.

-scott
