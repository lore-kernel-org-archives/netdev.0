From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] gso: Handle Trans-Ether-Bridging protocol in
 skb_network_protocol()
Date: Wed, 8 May 2013 09:23:13 -0700
Message-ID: <20130508092313.677f9717@nehalam.linuxnetplumber.net>
References: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
	<518A01F9.8090403@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: PJ Waskiewicz <peter.p.waskiewicz.jr@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:33084 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755526Ab3EHQ2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 May 2013 12:28:20 -0400
Received: by mail-pb0-f47.google.com with SMTP id uo1so1332174pbc.34
        for <netdev@vger.kernel.org>; Wed, 08 May 2013 09:28:19 -0700 (PDT)
In-Reply-To: <518A01F9.8090403@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 08 May 2013 00:42:49 -0700
PJ Waskiewicz <peter.p.waskiewicz.jr@linux.intel.com> wrote:

> On 5/7/2013 11:41 PM, Pravin B Shelar wrote:
> > Rather than having logic to calculate inner protocol in every
> > tunnel gso handler move it to gso code. This simplifies code.
> 
> Moving code that isn't used on a regular basis to hotpath for most 
> networking to simplify code isn't always a good thing.
> 
> Have you run tests on non-tunneled streams using GSO to make sure there 
> isn't an adverse impact to performance due to the new, untaken branch?
> 
> -PJ
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Maybe use unlikely here?
It looks like more and more of this tunnel unwrapping needs to be handled here
(vxlan? ipip?) probably want more general switch statement and per-protocol functions.
