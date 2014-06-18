From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 0/6] A step closer to RFC 6458 compliancy
Date: Wed, 18 Jun 2014 13:16:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725E8B7@AcuExch.aculab.com>
References: <1403017296-28469-1-git-send-email-geirola@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725DEC9@AcuExch.aculab.com>
 <53A08C10.70103@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725E555@AcuExch.aculab.com>
 <84A786A6-D242-4DC6-8FC4-573A91A88311@lurchi.franken.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Geir Ola Vaagland <geirola@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Michael Tuexen' <Michael.Tuexen@lurchi.franken.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:43318 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S966599AbaFRNRt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 09:17:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31393-04 for <netdev@vger.kernel.org>;
 Wed, 18 Jun 2014 14:17:40 +0100 (BST)
In-Reply-To: <84A786A6-D242-4DC6-8FC4-573A91A88311@lurchi.franken.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Tuexen [ 
> On 18 Jun 2014, at 10:42, David Laight <David.Laight@ACULAB.COM> wrote:
> 
> > From: Vlad Yasevich
> >> On 06/17/2014 11:36 AM, David Laight wrote:
> >>> From: Of Geir Ola Vaagland
> >>>> These patches are part of my master thesis project. I have been searching for discrepancies
> between
> >>>> the socket API specificiation in RFC 6458 and the current Linux SCTP implementation. The
> following
> >>>> patches are my humble attempts at getting somewhat closer to compliancy.
> >>>
> >>> I've just been reading RFC 6458 - HTF did it get past the editors and
> >>> then published in its current form?
> >>> Lots of the structures have implied padding.
> > ...
> >> I've argued the padding issue, but the editor stance is that it's implementation
> >> dependent.
> >
> > It wouldn't be as bad if the RFC said that the structure contained the
> > fields that followed (as is typical of the posix definitions),
> > but instead it gives a definition of the structure.

> That would have been a possibility, but it was never suggested.
> As far as I know, C does not guarantee the memory layout for structs,
> except for the sequence of the components. So a compiler might add
> some padding at any place. When implementing this, you need to take
> care of this (and your job might be simpler, since you might only
> work with a specific set of compilers).
> In FreeBSD we also added some padding to some structures since they
> "evolved" during the lifetime of of the internet draft and we wanted
> to preserve some compatibility.
> I agree, that one must take care of the implied padding and I will double
> check how this is handled in FreeBSD. Not sure...

You need to add explicit named pad fields in order to zero them.
(since you don't really want a memset())
That is against my reading of the RFC.

What does FreeBSD do about the 'sockaddr_storage'?
I'd have thought it had the same rules as NetBSD - where (IIRC) it should never
be instantiated, but only exists as a pointer type for function parameters.

	David
