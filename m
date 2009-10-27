From: Andreas Petlund <apetlund@simula.no>
Subject: [PATCH 0/3] net: TCP thin-stream latency-improving modifications
Date: Tue, 27 Oct 2009 17:28:34 +0100
Message-ID: <4AE71FB2.9080107@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	ilpo.jarvinen@helsinki.fi, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward1.uio.no ([129.240.10.70]:51775 "EHLO
	mail-forward1.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755949AbZJ0Q2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 12:28:42 -0400
Received: from exim by mail-out1.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1N2ouc-0005MB-Jq
	for netdev@vger.kernel.org; Tue, 27 Oct 2009 17:28:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a series of patches enabling non-intrusive, dynamically triggered modifications that improves retransmission latencies for thin streams.

The patches are based on the original modifications posted in this RFC:

http://article.gmane.org/gmane.linux.rt.user/3674/match=
http://article.gmane.org/gmane.linux.kernel/779290/match=

We have done our best to address the feedback from the RFC in the new patch set.

TCP streams with high interarrival time between packets (thin streams) are often found to be produced by interactive/time-dependent applications. Such streams are not able to trigger fast retransmissions, since too few dupACKs are received before a retransmission by timeout occurs. Exponential backoff also leads to large delays. Since the applications producing such data patterns are very often time-dependent, this causes delays that are very disturbing for the application performance/experience. This set of patches introduce two simple modifications that improves the latencies for thin streams:

1) If the stream is thin, fast retransmit on the first dupACK.
2) If the stream is thin, do not apply exponential backoff.

The modifications are only active if specifically enabled by syscontrol or iocontrol. If enabled, the thin-stream detection is dynamically triggering the modifications on and off based on the current number of packets in flight. Thus, regular (greedy) streams do not trigger the modifications.

The modifications are thoroughly tested and found to improve retransmission latency considerably without negatively influencing fairness. This is also the case when very many streams using the modifications share a common bottleneck.

We have also developed a bundling mechanism (see the RFC linked to above) that can be used in thin-stream scenarios where the packet sizes are small. This mechanism is more intrusive, and will be posted for the net-next tree when we have revised the design.

For more information on time-dependent thin streams and the modifications, please refer to the articles linked to below:

http://simula.no/research/networks/publications/Simula.ND.159/simula_pdf_file
http://simula.no/research/networks/publications/Simula.ND.185/simula_pdf_file
http://simula.no/research/networks/publications/Simula.ND.112/simula_pdf_file
http://simula.no/research/networks/publications/Simula.ND.35/simula_pdf_file

Cheers, 
Andreas

