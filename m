From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Sun, 24 Apr 2016 11:54:33 +0200
Message-ID: <20160424115433.5c0a63ab@griffin>
References: <cover.1461346798.git.jbenc@redhat.com>
	<017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
	<CAOrHB_DrFXg=nQAdscOgX8nbUoOC4fMsWiN6R4n907zB5rtD=g@mail.gmail.com>
	<20160422232732.7dfd0ec3@griffin>
	<CAOrHB_DXzE8XNBmMc_VLzz+hkJCUmMVT2uMhWORCgq+g7ym9HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Simon Horman <simon.horman@netronome.com>
To: pravin shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752221AbcDXJyh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Apr 2016 05:54:37 -0400
In-Reply-To: <CAOrHB_DXzE8XNBmMc_VLzz+hkJCUmMVT2uMhWORCgq+g7ym9HA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Apr 2016 20:40:13 -0700, pravin shelar wrote:
> But skb->protocol is not set to ETH_P_TEB anywhere in ip-gre module.
> Am I missing something?

Ah, I see your point. It needs to be solved a bit differently, though,
we need to call __iptunnel_pull_header instead of iptunnel_pull_header
for these packets. I'll rework the patch.

> ip_tunnel_rcv() checks device type (tunnel->dev->type) to perform
> ethernet specific processing on packet. I think that should be changed
> to check packet type.

The current behavior is correct. The Ethernet processing depends on
the interface type, ARPHRD_IPGRE interfaces can't treat Ethernet
headers as L2 headers, that wouldn't match the interface type.

 Jiri
