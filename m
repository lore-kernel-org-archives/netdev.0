From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/2] Get rid of "multi-hh_cache" capability.
Date: Wed, 13 Jul 2011 01:52:10 -0700 (PDT)
Message-ID: <20110713.015210.1765961853698948606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48473 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965064Ab1GMIwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 04:52:13 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6D8qAk1016934
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 01:52:12 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We support having multiple hh_cache entries in a list hung off
of a neighbour entry, one per unique ->hh_type protocol value.

Problem is, nobody uses this.

Neighbour entries are for one protocol type only (which determines the
type of the key), whose protocol is "dst_ops->protocol".

Kill all of this noise, which dates back to before Alexey Kuznetsov
added the neighbour layer.  He just blinded copied over this
capability into the generic layer.

The next step will be to embed "struct hh_cache" directly into "struct
neighbour".  Validity will be indicated by a non-zero hh_len.

Then we can get rid of all of this extra memory allocations, funky
refcounting, and SMP memory barriers.

And finally, move to refcount-less neigh entry usage in ip_finish_output2()
