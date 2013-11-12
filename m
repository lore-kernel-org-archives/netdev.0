From: Dave Jones <davej@redhat.com>
Subject: shutdown(3) and bluetooth.
Date: Tue, 12 Nov 2013 16:11:25 -0500
Message-ID: <20131112211125.GA2912@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab3KLVLf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Nov 2013 16:11:35 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rACLBYQa008400
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 16:11:34 -0500
Received: from gelk.kernelslacker.org (ovpn-113-184.phx2.redhat.com [10.3.113.184])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rACLBSwQ007822
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 16:11:34 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id rACLBRt9003763
	for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 16:11:27 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id rACLBPjF003762
	for netdev@vger.kernel.org; Tue, 12 Nov 2013 16:11:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is shutdown() allowed to block indefinitely ? The man page doesn't say either way,
and I've noticed that my fuzz tester occasionally hangs for days spinning in bt_sock_wait_state()

Is there something I should be doing to guarantee that this operation
will either time out, or return instantly ?

In this specific case, I doubt anything is on the "sender" end of the socket, so
it's going to be waiting forever for a state change that won't arrive.

	Dave
