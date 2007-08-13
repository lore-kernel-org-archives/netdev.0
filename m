From: Shay Goikhman <GOIKHMAN@il.ibm.com>
Subject: Problem with semantics?
Date: Mon, 13 Aug 2007 20:07:50 +0300
Message-ID: <OFF8FEF8BA.07073375-ONC2257336.005DB73A-C2257336.005E19ED@il.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:13058 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968571AbXHMRHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 13:07:34 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id l7DH7V19175938
	for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 17:07:31 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l7DH7Vg72089058
	for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 19:07:31 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7DH7Vj6015762
	for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 19:07:31 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Dear Linux maintainers,

 I'm doing :

      setsockopt(s,  SO_RCVTIMEO, t1 );                  // set time-out
t1 on socket while block receiving on it
      select(,,, &fd_set_including(s), .., &errs, t2);      // block till
receive or time-out  t 2 jointly on a set of sockets

Apparently, I could no find reference on the coupled behavior of the two
above statements in Linux documentation.
As I understand the blocking semantics, I would expect  that  if t1<t2 ,
select should return after t1 with the descriptor 's' in 'errs' if 's' does
not become readable in the t1 interval.

It is not so in life -- select ignores t1 altogether.

Do you have some enlightening knowledge on the matter?
Thanks,
-Shay

