From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 0/2] xfrm: Remove ancient sleeping code
Date: Thu, 10 Oct 2013 08:33:01 +0200
Message-ID: <20131010063301.GO7660@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:38364 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751491Ab3JJGdF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:33:05 -0400
Received: from localhost (alg1 [127.0.0.1])
	by a.mx.secunet.com (Postfix) with ESMTP id 4B14C1A007E
	for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:33:03 +0200 (CEST)
Received: from a.mx.secunet.com ([127.0.0.1])
	by localhost (a.mx.secunet.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id itFAXrxVwUpp for <netdev@vger.kernel.org>;
	Thu, 10 Oct 2013 08:33:02 +0200 (CEST)
Received: from mail-srv1.secumail.de (unknown [10.53.40.200])
	by a.mx.secunet.com (Postfix) with ESMTP id 3867F1A007B
	for <netdev@vger.kernel.org>; Thu, 10 Oct 2013 08:33:02 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does anyone still rely on the ancient sleeping when the SA is in
acquire state? It is disabled by default since more that five years,
but can cause indefinite task hangs if enabled and the needed state
does not get resolved.

We now queue packets to the policy if the states are not yet resolved
if we are in a code path that can not sleep. We could do this even in
the case we can sleep. As a bonus, we can remove the FLOWI_FLAG_CAN_SLEEP
flag because the only thing this flag does, is to notify xfrm that we are
in a codepath that can sleep.

The two RFC patches to remove the sleeping code are in reply to this
mail. I'd add this to the ipsec-next tree if there are no objections.
