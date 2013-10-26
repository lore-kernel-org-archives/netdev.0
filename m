From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: vxlan gso is broken by stackable gso_segment()
Date: Fri, 25 Oct 2013 17:52:22 -0700
Message-ID: <1382748742.4032.24.camel@edumazet-glaptop.roam.corp.google.com>
References: <CAMEtUuzswOVA6UkPRjS-O=gOe9BLLJ5qaAG_eAd_fTqDJo8ofA@mail.gmail.com>
	 <1382674000.7572.75.camel@edumazet-glaptop.roam.corp.google.com>
	 <1382692140.7572.79.camel@edumazet-glaptop.roam.corp.google.com>
	 <20131025.181809.348808013109842304.davem@davemloft.net>
	 <CAMEtUuxwi05oX0TqNdMbjy04MT=ZLemLXJQTTcAMrnWuhXLKdQ@mail.gmail.com>
	 <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:58890 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751564Ab3JZAwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 20:52:25 -0400
Received: by mail-ea0-f180.google.com with SMTP id l9so853623eaj.11
        for <netdev@vger.kernel.org>; Fri, 25 Oct 2013 17:52:24 -0700 (PDT)
In-Reply-To: <1382743502.4032.6.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-25 at 16:25 -0700, Eric Dumazet wrote:

> Please note the original performance is not that good, you mentioned 230
> Mbps on lxc, while I get more than 5Gb/s on a 10G link.
> 
> This should be investigated ...

This is probably trivial to increase performance :

veth currently do not support any kind of tunneling TSO :

tx-fcoe-segmentation: off [fixed]
tx-gre-segmentation: off [fixed]
tx-ipip-segmentation: off [fixed]
tx-sit-segmentation: off [fixed]
tx-udp_tnl-segmentation: off [fixed]
tx-mpls-segmentation: off [fixed]

I'll submit a patch for net-next
