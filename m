From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: LRO disable warnings on kernel 2.6.38
Date: Mon, 21 Mar 2011 11:04:12 +0100
Message-ID: <1300701852.10934.67.camel@firesoul.comx.local>
References: <1300446743.11985.317.camel@firesoul.comx.local>
	 <4D8385CE.1060205@intel.com>
	 <1300699294.10934.63.camel@firesoul.comx.local>
	 <1300700708.2884.10.camel@edumazet-laptop>
	 <1300701232.2884.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:49803 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444Ab1CUKEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 06:04:14 -0400
In-Reply-To: <1300701232.2884.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-03-21 at 10:53 +0100, Eric Dumazet wrote:
> Couly you please send us the result of "ethtool -k eth01" to make sure
> its the problem ?

prod server:

albpd4:~# ethtool -k eth01
Offload parameters for eth01:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: on
ntuple-filters: off
receive-hashing: off

pre-prod server:

albpd1:~# ethtool -k eth01
Offload parameters for eth01:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
ntuple-filters: off
receive-hashing: off

Hmm... notice how the large-receive-offload (LRO) is different on the
two machines.

I cannot disable LRO with userspace ethtool:

albpd4:~# ethtool -K eth01 lro off
Cannot set large receive offload settings: Invalid argument

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer


