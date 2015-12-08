From: roopa <roopa@cumulusnetworks.com>
Subject: Re: MPLS decap with iproute2
Date: Mon, 07 Dec 2015 18:37:00 -0800
Message-ID: <5666424C.3050801@cumulusnetworks.com>
References: <CAJm+voVUXPBXBRo98K6XS9pVEkN=fCJ4chRdQ=azcZO9ge9gEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sam Russell <sam.h.russell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36361 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932193AbbLHCnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 21:43:47 -0500
Received: by pfdd184 with SMTP id d184so3970961pfd.3
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 18:43:46 -0800 (PST)
In-Reply-To: <CAJm+voVUXPBXBRo98K6XS9pVEkN=fCJ4chRdQ=azcZO9ge9gEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/7/15, 11:42 AM, Sam Russell wrote:
> Hi,
>
> I've had success with the iproute2 manpage example for encapsulating
> outgoing traffic in MPLS, but I've not found a way to add decap routes
> inbound.
>
> I've tried "ip route -f mpls add 100 dev lo" and other variations, but I
> get netlink errors back.
>
> Has this been built yet? Is there sample config that I can try out? I'm
> running a home-built 4.3 kernel + iproute2 built from head (on ubuntu
> 15.10) and am comfortable with perf and splashing around in the codebase if
> need be.
>
Example below should work
 ip -f mpls route add 100 as 200 via inet 10.1.1.2 dev eth0

You have to enable mpls on the interface first:
echo 1 > /proc/sys/net/mpls/conf/eth0/input

multipath iproute2 patches are not in yet. Will submit them soon.

let me know if you still get errors.
