From: =?gb2312?B?zfXl4w==?= <shankerwangmiao@gmail.com>
Subject: Re: [Question] Should `CAP_NET_ADMIN` be needed when opening `/dev/ppp`?
Date: Tue, 3 May 2016 21:08:45 +0800
Message-ID: <04054B5D-AD85-47ED-8666-21C7399BC121@gmail.com>
References: <2BEB0C68-EBC6-4A8F-A751-DE8F4A2C9D2C@gmail.com> <20160503101240.GA1304@alphalink.fr> <CAFLxGvyKMbJyfk5oiRZ6-67yHH=f+3mkY=gd3AsZC1G_o0Xhxg@mail.gmail.com> <1462274614.1336993.596603129.675ECADD@webmail.messagingengine.com>
Mime-Version: 1.0 (Mac OS X Mail 9.2 \(3112\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Weinberger <richard.weinberger@gmail.com>,
	Guillaume Nault <g.nault@alphalink.fr>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462274614.1336993.596603129.675ECADD@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> =D4=DA 2016=C4=EA5=D4=C23=C8=D5=A3=AC=CF=C2=CE=E77:23=A3=ACHannes Fre=
deric Sowa <hannes@stressinduktion.org> =D0=B4=B5=C0=A3=BA
>=20
> On Tue, May 3, 2016, at 12:35, Richard Weinberger wrote:
>> On Tue, May 3, 2016 at 12:12 PM, Guillaume Nault <g.nault@alphalink.=
fr>
>> wrote:
>>> On Sun, May 01, 2016 at 09:38:57PM +0800, Wang Shanker wrote:
>>>> static int ppp_open(struct inode *inode, struct file *file)
>>>> {
>>>>      /*
>>>>       * This could (should?) be enforced by the permissions on /de=
v/ppp.
>>>>       */
>>>>      if (!capable(CAP_NET_ADMIN))
>>>>              return -EPERM;
>>>>      return 0;
>>>> }
>>>> ```
>>>>=20
>>>> I wonder why CAP_NET_ADMIN is needed here, rather than leaving it =
to the
>>>> permission of the device node. If there is no need, I suggest that=
 the
>>>> CAP_NET_ADMIN check be removed.
>>>>=20
>>> If this test was removed here, then it'd have to be added again in =
the
>>> PPPIOCNEWUNIT ioctl, at the very least, because creating a netdevic=
e
>>> should require CAP_NET_ADMIN. Therefore that wouldn't help for your
>>> case.
>>> I don't know why the test was placed in ppp_open() in the first pla=
ce,
>>> but changing it now would have side effects on user space. So I'd
>>> rather leave the code as is.
>>=20
>> I think the question is whether we really require having CAP_NET_ADM=
IN
>> in the initial namespace and not just in the current one.
>> Is ppp not network namespace aware?
>=20
> I agree, ns_capable(net->user_ns, CAP_NET_ADMIN), would probably make
> more sense.
I agree with that.
>=20
> Bye,
> Hannes
