From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan gso is broken by stackable gso_segment()
Date: Thu, 24 Oct 2013 17:41:47 -0700
Message-ID: <1382661707.7572.73.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAMEtUuxRhENE+OCFgdVASyVAaLo8AOdazUZdT+YHrcEzWA8Dow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:54038 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415Ab3JYAlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 20:41:52 -0400
Received: by mail-ee0-f44.google.com with SMTP id c4so1023505eek.31
        for <netdev@vger.kernel.org>; Thu, 24 Oct 2013 17:41:50 -0700 (PDT)
In-Reply-To: <CAMEtUuxRhENE+OCFgdVASyVAaLo8AOdazUZdT+YHrcEzWA8Dow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-10-24 at 16:37 -0700, Alexei Starovoitov wrote:
> Hi Eric, Stephen,
> 
> it seems commit 3347c960 "ipv4: gso: make inet_gso_segment() stackable"
> broke vxlan gso
> 
> the way to reproduce:
> start two lxc with veth and bridge between them
> create vxlan dev in both containers
> do iperf
> 
> this setup on net-next does ~80 Mbps and a lot of tcp retransmits.
> reverting 3347c960 and d3e5e006 gets performance back to ~230 Mbps
> 
> I guess vxlan driver suppose to set encap_level ? Some other way?

Hi Alexei

Are the GRE tunnels broken as well for you ?

In my testings, GRE was working, and it looks GRE and vxlan has quite
similar gso implementation.

Maybe you can capture some of the broken frames with tcpdump ?
