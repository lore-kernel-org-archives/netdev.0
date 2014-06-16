From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP seems to lose its socket state.
Date: Mon, 16 Jun 2014 14:46:22 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725D0F0@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com>
 <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com>
 <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com>
 <539638EB.9010802@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725C172@AcuExch.aculab.com>
 <539B4794.4010700@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725CDEF@AcuExch.aculab.com>
 <539EF57D.6080008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Vlad Yasevich' <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60415 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751660AbaFPOrb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 10:47:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 14678-02 for <netdev@vger.kernel.org>;
 Mon, 16 Jun 2014 15:47:22 +0100 (BST)
In-Reply-To: <539EF57D.6080008@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich [mailto:vyasevich@gmail.com]
> On 06/16/2014 04:40 AM, David Laight wrote:
...
> > I wonder why commands get queued, rather than just actioned with
> > an immediate function call?
> 
> I don't know precisely why this decision was make in the 2.5 days
> (before my time).  If I had to guess, I'd say that it was simple
> to do at the time to provide a kind of buffering of multiple
> actions that resulted from processing of multiple chunks.

It rather goes with the arrays of function pointers rather than
switch statements for the per-state actions.

I'd guess that originally the list of 'actions' was made of dynamically
allocated blocks. They might have been processed much later on, but that
would give lots of timing issues.
The other possible reason was to make it easier to trace actions,
but any generic trace ends up missing the important 'state' info
so is almost useless after the initial debug.

If the actions get accumulated across chunks, then the list will
never be large enough.
OTOH I think they are now cleared after each chunk has been processed.

	David
