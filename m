From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 2/2] tc: make ingress and egress qdiscs
 consistent
Date: Wed, 08 Apr 2015 12:32:08 -0400 (EDT)
Message-ID: <20150408.123208.890310178000649038.davem@davemloft.net>
References: <55252FEF.40201@iogearbox.net>
	<55253289.8020306@mojatatu.com>
	<552556BC.8020108@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, daniel@iogearbox.net, jiri@resnulli.us,
	tgraf@suug.ch, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39171 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754140AbbDHQcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 12:32:10 -0400
In-Reply-To: <552556BC.8020108@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Wed, 08 Apr 2015 09:26:36 -0700

> My preference is to add 'needs_l2' flag to ingress qdisc.

The problem is that needs_l2 is not property of individual qdisc,
but conditionally 1 or more things sitting behind it.

You can mix u32 and bpf classifiers.  One wants need_L2 another
does not, and you therefore cannot handle this problem in this
manner.

Face it, we're stuck with what we have.  And I think you will
have to adjust generated bpf program based upon whether it is
being attacked to ingress or egress qdisc.
