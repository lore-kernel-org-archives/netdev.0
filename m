From: Alexei Starovoitov <ast@plumgrid.com>
Subject: vxlan gso is broken by stackable gso_segment()
Date: Thu, 24 Oct 2013 16:37:52 -0700
Message-ID: <CAMEtUuxRhENE+OCFgdVASyVAaLo8AOdazUZdT+YHrcEzWA8Dow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:34846 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751722Ab3JXXhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 19:37:54 -0400
Received: by mail-wi0-f181.google.com with SMTP id l12so302100wiv.8
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 16:37:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric, Stephen,

it seems commit 3347c960 "ipv4: gso: make inet_gso_segment() stackable"
broke vxlan gso

the way to reproduce:
start two lxc with veth and bridge between them
create vxlan dev in both containers
do iperf

this setup on net-next does ~80 Mbps and a lot of tcp retransmits.
reverting 3347c960 and d3e5e006 gets performance back to ~230 Mbps

I guess vxlan driver suppose to set encap_level ? Some other way?

Thanks
Alexei
