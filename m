From: Dan Williams <dcbw@redhat.com>
Subject: pppoe.ko intercepts PADT frames and leaves pppd ignorant
Date: Wed, 30 Oct 2013 15:09:13 -0500
Message-ID: <1383163753.21123.22.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44480 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754429Ab3J3UJU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 16:09:20 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r9UK9KMP012378
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 16:09:20 -0400
Received: from [10.3.112.4] ([10.3.112.4])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id r9UK9JrZ018354
	for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 16:09:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I noticed that pppd is completely ignorant of kernel handling of PADT
frames; they will cause the kernel to terminate the PPPoE connection,
but pppd continues blissfully on until the LCP echo timeout.  Ideally
pppd/rp-pppoe would notice that a PADT was received, and could then
clean up immediately.  This apparently happens fine with usermode PPPoE,
but not with kernel PPPoE.

pppoe_disc_rcv() intercepts PADT and verifies it, and then drops it on
the floor.  How is userland supposed to know that the PPPoE session is
now a zombie and the PPP session should be cleaned up?

Thanks,
Dan
