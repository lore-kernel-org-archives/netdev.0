From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] bridge: Fix incorrect judgment of promisc
Date: Thu, 5 Jun 2014 13:47:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17257DCF@AcuExch.aculab.com>
References: <1401965851-6449-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <063D6719AE5E284EB5DD2968C1650D6D17257C08@AcuExch.aculab.com>
 <539052C0.2090409@lab.ntt.co.jp>
 <063D6719AE5E284EB5DD2968C1650D6D17257D43@AcuExch.aculab.com>
 <53906B30.7080907@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>
To: 'Toshiaki Makita' <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49575 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751174AbaFENr7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 09:47:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16976-10 for <netdev@vger.kernel.org>;
 Thu,  5 Jun 2014 14:47:51 +0100 (BST)
In-Reply-To: <53906B30.7080907@lab.ntt.co.jp>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Toshiaki Makita 
> > A quick truth table:
> > 	auto_cnt	auto_port	set/clear
> > 		0		0	clear
> > 		0		1	clear
> > 		1		0	set
> > 		1		1	clear
> > 		2+		0/1	clear
> 
> The last line should be set.

I've clearly not drunk enough coffee today...

I suspect the 0-1 line is impossible.
Since the check is probably for 'any other ports in 'auto' mode'.
So:
	if (auto_cnt - auto_port > 0)
(which is much the same as the original) is a good descriptive test.

	David
