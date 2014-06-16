From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: SCTP seems to lose its socket state.
Date: Mon, 16 Jun 2014 09:47:41 -0400
Message-ID: <539EF57D.6080008@gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1724E53D@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17258A67@AcuExch.aculab.com> <063D6719AE5E284EB5DD2968C1650D6D17259993@AcuExch.aculab.com> <539638EB.9010802@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1725C172@AcuExch.aculab.com> <539B4794.4010700@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D1725CDEF@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f179.google.com ([209.85.216.179]:52491 "EHLO
	mail-qc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751468AbaFPNrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 09:47:45 -0400
Received: by mail-qc0-f179.google.com with SMTP id x3so6709544qcv.10
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2014 06:47:44 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725CDEF@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/16/2014 04:40 AM, David Laight wrote:
> From: Vlad Yasevich
> ...
>> Yeah.  We do end up queuing a bit more commands. Need to see if
>> all them are necessary..
> 
> I wonder why commands get queued, rather than just actioned with
> an immediate function call?

I don't know precisely why this decision was make in the 2.5 days
(before my time).  If I had to guess, I'd say that it was simple
to do at the time to provide a kind of buffering of multiple
actions that resulted from processing of multiple chunks.

> I suspect it is steeped into the history of the code.
>

Yes, very much so.  There are some papers/presentations describing
the approach, but not the reasons fro why it was taken.

> All of the commands have to be (and are) actioned before any other
> packets (etc) can be processed otherwise there will be massive
> problems with the socket/association state.
> 
> Simply calling the functions is likely change the order of the
> actions - which might break things.
> OTOH direct calls would make it much easier to audit the sequences.
> 

I've been thinking for long time about how to change this, but it really
needs a very careful audit and implementation.

-vlad
