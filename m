From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 28 Jul 2015 12:51:57 -0700
Message-ID: <20150728125157.10917b0b@urahara>
References: <55B6E8AC.4060600@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jmorris@namei.org" <jmorris@namei.org>
To: Richard Laing <Richard.Laing@alliedtelesis.co.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:33677 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146AbbG1Tvs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 15:51:48 -0400
Received: by pdbnt7 with SMTP id nt7so75700859pdb.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 12:51:47 -0700 (PDT)
In-Reply-To: <55B6E8AC.4060600@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jul 2015 02:27:57 +0000
Richard Laing <Richard.Laing@alliedtelesis.co.nz> wrote:

> From: Richard Laing <richard.laing@alliedtelesis.co.nz>
> 
> Enable flow-based ECMP.
> 
> Currently if equal-cost multipath is enabled the kernel chooses between
> equal cost paths for each matching packet, essentially packets are
> round-robined between the routes. This means that packets from a single
> flow can traverse different routes. If one of the routes experiences
> congestion this can result in delayed or out of order packets arriving
> at the destination.
> 
> This patch allows packets to be routed based on their
> flow - packets in the same flow will always use the same route. This
> prevents out of order packets. There are other issues with round-robin
> based ECMP routing related to variable path MTU handling and debugging.
> See RFC2991 for more details on the problems associated with packet
> based ECMP routing.
> 
> This patch relies on the skb hash value to select between routes. The
> selection uses a hash-threshold algorithm (see RFC2992).
> 
> Signed-off-by: Richard Laing <richard.laing@alliedtelesis.co.nz>

ECMP needs some work, glad to see someone has started again.
A little bit of history, the original ECMP algorithm selection code was dropped years ago
because it was buggy. The API was good, but the implemenation had problems.

Somewhere in my dustbin, I have some patches from internal stuff that allows
selecting the algorithm at runtime.

Your implementation makes it a compile time choice. Although this is good
for testing, it really needs to be a sysctl or route attribute to be
useful in a distro environment.

As others said, your mailer is mangling the lines by wrapping.
