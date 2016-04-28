From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net 3/3] gre: receive also TEB packets for lwtunnels
Date: Thu, 28 Apr 2016 10:23:35 +0200
Message-ID: <20160428102335.7cff8166@griffin>
References: <cover.1461346798.git.jbenc@redhat.com>
	<017d8f2b1c00e8fdbdb92a5898b1b5f365b58d6d.1461346798.git.jbenc@redhat.com>
	<20160428064915.GA29503@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36314 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752666AbcD1IXk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 04:23:40 -0400
In-Reply-To: <20160428064915.GA29503@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Apr 2016 16:49:19 +1000, Simon Horman wrote:
> I have had some success wiring up Open vSwitch to use this patch for
> transmit. However, I am wondering if something more is needed to allow
> differentiation between packets with and without an L2 header present
> on receive.

The problem, as Pravin pointed out, is the patch does not correctly set
skb->protocol to ETH_P_TEB because of special handling of ETH_P_TEB in
iptunnel_pull_header. This will be fixed in v2 of the patch.

No flag will be needed then, just use skb->protocol.

 Jiri
