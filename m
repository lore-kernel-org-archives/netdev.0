From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [take23 0/5] kevent: Generic event handling mechanism.
Date: Thu, 09 Nov 2006 08:24:22 +0100
Message-ID: <4552D7A6.4060505@cosmosbay.com>
References: <1154985aa0591036@2ka.mipt.ru>
 <20061107141718.f7414b31.akpm@osdl.org> <20061108082147.GA2447@2ka.mipt.ru>
 <200611081551.14671.dada1@cosmosbay.com>
 <20061108140307.da7d815f.akpm@osdl.org>
 <Pine.LNX.4.64.0611081442420.23154@alien.or.mcafeemobile.com>
 <45526339.3040506@cosmosbay.com>
 <Pine.LNX.4.64.0611081526350.23154@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@osdl.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753370AbWKIHYV@vger.kernel.org>
In-reply-to: <Pine.LNX.4.64.0611081526350.23154@alien.or.mcafeemobile.com>
To: Davide Libenzi <davidel@xmailserver.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Davide Libenzi a =E9crit :
> On Thu, 9 Nov 2006, Eric Dumazet wrote:
>=20
>> Davide Libenzi a ?crit :
>>> I don't care about both ways, but sys_poll() does the same thing ep=
oll does
>>> right now, so I would not change epoll behaviour.
>>>
>> Sure poll() cannot return a partial count, since its return value is=
 :
>>
>> On success, a positive number is returned, where the number returned=
 is
>>        the  number  of structures which have non-zero revents fields=
 (in other
>>        words, those descriptors with events or errors reported).
>>
>> poll() is non destructive (it doesnt change any state into kernel). =
Returning
>> EFAULT in case of an error in the very last bit of user area is mand=
atory.
>>
>> On the contrary :
>>
>> epoll_wait() does return a count of transfered events, and update so=
me state
>> in kernel (it consume Edge Trigered events : They can be lost foreve=
r if not
>> reported to user)
>>
>> So epoll_wait() is much more like read(), that also updates file sta=
te in
>> kernel (current file position)
>=20
> Lost forever means? If there are more processes watching some fd=20
> (external events), they all get their own copy of the events in their=
 own=20
> private epoll fd. It's not that we "steal" things out of the kernel, =
is=20
> not a 1:1 producer/consumer thing (one producer, 1 queue). It's one=20
> producer, broadcast to all listeners (consumers) thing. The only case=
=20
> where it'd matter is in the case of multiple threads sharing the same=
=20
> epoll fd.

In my particular epoll application, the producer is tcp stack, and I ha=
ve one=20
consumer. If an network event is lost in the EFAULT handling, its lost=20
forever. In any case, my application do provide a correct user area, so=
 this=20
problem is only theorical.

> In general, I'd be more for having the userspace get his own SEGFAULT=
=20
> instead of letting it go with broken parameters. If I'm coding usersp=
ace,=20
> and I'm doing something wrong, I like the kernel to let me know, inst=
ead=20
> of trying to fix things for me.
> Also, epoll can easily be fixed (add a param to ep_reinject_items() t=
o=20
> re-inject items in case of error/EFAULT) to leave events in the ready=
-list=20
> and let the EFAULT emerge.=20

Please dont slow the hot path for a basically "User Error". It's alread=
y=20
tested in the transfert function, with two conditional branches for eac=
h=20
transfered event.

> Anyone else has opinions about this?
>=20
>=20
>=20
>=20
> PS: Next time it'd be great if you Cc: me when posting epoll patches,=
 so=20
>     you avoid Andrew the job of doing it.

Yes, but this particular patch was a followup on own kevent Andrew patc=
h.

I have a bunch of patches for epoll I will send to you :)

Eric
