From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next 0/3 v3] changes to make ipv4 routing table aware
 of next-hop link status
Date: Wed, 10 Jun 2015 20:07:10 -0700
Message-ID: <CAE4R7bChX1AtwoeC12ei1hr-3CJnZwPig8YXKpvAuhHSRyVYLg@mail.gmail.com>
References: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, ddutt@cumulusnetworks.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:33182 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbFKDHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2015 23:07:31 -0400
Received: by qgfa66 with SMTP id a66so21982913qgf.0
        for <netdev@vger.kernel.org>; Wed, 10 Jun 2015 20:07:31 -0700 (PDT)
In-Reply-To: <1433990233-958-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 10, 2015 at 7:37 PM, Andy Gospodarek
<gospo@cumulusnetworks.com> wrote:

> There was also a request for switchdev support for this, but that will be
> posted as a followup as switchdev does not currently handle dead
> next-hops in a multi-path case and I felt that infra needed to be added
> first.

That's not true.  switchdev_fib_ipv4_add() passes *fi and all of the
nexthops for the route are hanging off of that, including the
nh->flags where you're setting LINKDOWN.  Multipath is not different
than singlepath in that regard.  Same API for both.  switchdev support
should be added for this NEW feature, especially since you're using
the feature to offload to a switch device.
