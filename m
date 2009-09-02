From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH net-next-2.6] ip: Report qdisc packet drops
Date: Wed, 2 Sep 2009 14:37:59 -0500 (CDT)
Message-ID: <alpine.DEB.1.10.0909021413490.16364@V090114053VZO-1>
References: <4A98132C.8090105@gmail.com> <20090828.233858.256193304.davem@davemloft.net> <4A9BBD8E.2010303@gmail.com> <20090901.184121.06750444.davem@davemloft.net> <4A9E849A.30105@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, sri@us.ibm.com,
	dlstevens@us.ibm.com, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, mtk.manpages@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:45084 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752823AbZIBPjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 11:39:08 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3BF9082C420
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 11:40:52 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id asNMTpRvdh8P for <netdev@vger.kernel.org>;
	Wed,  2 Sep 2009 11:40:52 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F179E82C622
	for <netdev@vger.kernel.org>; Wed,  2 Sep 2009 11:40:40 -0400 (EDT)
In-Reply-To: <4A9E849A.30105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The patch is smaller if you remove the handling of recverr completely from
ip_push_pending_frames() and return NET_RX_DROP etc. Two of the callers
never even inspect the return code. For them this is useless processing.

The others could handle the processing of recverr on their own. Doing so
voids adding code to ip_push_pending_frames() which is latency critical
and also avoids changing the calling conventions.

I have a draft here from our earlier disucssions but its not as
comprehensive as yours.


