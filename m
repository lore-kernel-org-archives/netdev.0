From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP seems to lose its socket state.
Date: Mon, 16 Jun 2014 08:40:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725CDEF@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
 <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com>
 <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com>
 <539638EB.9010802@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725C172@AcuExch.aculab.com>
 <539B4794.4010700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:53796 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754258AbaFPIlj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 04:41:39 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05284-06 for <netdev@vger.kernel.org>;
 Mon, 16 Jun 2014 09:41:30 +0100 (BST)
In-Reply-To: <539B4794.4010700@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich
...
> Yeah.  We do end up queuing a bit more commands. Need to see if
> all them are necessary..

I wonder why commands get queued, rather than just actioned with
an immediate function call?
I suspect it is steeped into the history of the code.

All of the commands have to be (and are) actioned before any other
packets (etc) can be processed otherwise there will be massive
problems with the socket/association state.

Simply calling the functions is likely change the order of the
actions - which might break things.
OTOH direct calls would make it much easier to audit the sequences.

	David
