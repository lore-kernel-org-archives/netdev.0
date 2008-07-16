From: David Miller <davem@davemloft.net>
Subject: Re: IPV4: Enable IP_ID sequencing for all traffic (inquiring minds
 want to know why its set to zero)
Date: Wed, 16 Jul 2008 14:01:00 -0700 (PDT)
Message-ID: <20080716.140100.20638484.davem@davemloft.net>
References: <487E4A6B.6040103@linux-foundation.org>
	<20080716.133048.201600858.davem@davemloft.net>
	<487E5C89.7050005@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, dlstevens@us.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754436AbYGPVBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 17:01:01 -0400
In-Reply-To: <487E5C89.7050005@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Wed, 16 Jul 2008 13:39:37 -0700

> I have vague recollections of wanting to avoid (then) locks on the 
> increment in the non-fragmented paths, assertions that covering cases 
> like intermediate devices ignoring DF and fragmenting anyway didn't 
> warrant concern etc.

Partially, yes.

If you look, we do increment the ID for TCP connections which will
be setting IP_DF, but we allocate such IDs in a socket-local manner
which keeps these allocations from depleating the real ID cache
for that destination.

This is legal because when IP_DF is set, the IDs serve no purpose.

We had to do this because TCP header compression, used by SLIP et
al., depends upon the ID value incrementing.

