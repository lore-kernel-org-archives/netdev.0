From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [take25 1/6] kevent: Description.
Date: Mon, 27 Nov 2006 11:20:28 -0800
Message-ID: <456B3A7C.20301@redhat.com>
References: <11641265982190@2ka.mipt.ru> <4564E162.8040901@redhat.com> <20061123115240.GA20294@2ka.mipt.ru> <4565FA60.9000402@redhat.com> <20061124110143.GF13600@2ka.mipt.ru> <456718A3.1070108@redhat.com> <20061124161406.GA5054@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Andrew Morton <akpm@osdl.org>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:25040 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S933340AbWK0TVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 14:21:00 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124161406.GA5054@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:

> If kernel has put data asynchronously it will setup special flag, thu=
s=20
> kevent_wait() will not sleep and will return, so thread will check ne=
w
> entries and process them.

This is not sufficient.

The userlevel code does not commit the events until they are processed.=
=20
  So assume two threads at userlevel, one event is asynchronously=20
posted.  The first thread picks it up, the second call kevent_wait.

With your scheme it will not be put to sleep and unnecessarily returns=20
to userlevel.

What I propose and what has been proven to work in many situations is t=
o=20
have part of the kevent_wait syscall the information about "I am aware=20
of all events up to XX; wake me only if anything beyond that is added".

Please take a look at how futexes work, it's really the same concept.=20
And it's really also simpler for the implementation.  Having such a fla=
g=20
is much more complicated than adding a simple index comparison before=20
going to sleep.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
