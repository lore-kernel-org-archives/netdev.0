From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: Kevent POSIX timers support.
Date: Mon, 27 Nov 2006 10:20:50 -0800
Message-ID: <456B2C82.7040700@redhat.com>
References: <20061120082500.GA25467@2ka.mipt.ru> <4562102B.5010503@redhat.com> <20061121095302.GA15210@2ka.mipt.ru> <45633049.2000209@redhat.com> <20061121174334.GA25518@2ka.mipt.ru> <20061121184605.GA7787@2ka.mipt.ru> <4563FE71.4040807@redhat.com> <20061122104416.GD11480@2ka.mipt.ru> <20061123085243.GA11575@2ka.mipt.ru> <456603E7.9090006@redhat.com> <20061124095052.GC13600@2ka.mipt.ru>
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
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:62866 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1757861AbWK0SVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 13:21:52 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061124095052.GC13600@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
>> We need to pass the data in the sigev_value meember of the struct=20
>> sigevent structure passed to timer_create to the caller.  I don't se=
e it=20
>> being done here nor when the timer is created.  Do I miss something?=
=20
>> The sigev_value value should be stored in the user/ptr member of str=
uct=20
>> ukevent.
>=20
> sigev_value was stored in k_itimer structure, I just do not know wher=
e
> to put it in the ukevent provided to userspace - it can be placed in
> pointer value if you like.

sigev_value is a union and the largest element is a pointer.  So,=20
transporting the pointer value is sufficient and it should be passed up=
=20
to the user in the ptr member of struct ukevent.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
