From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Wed, 09 Jan 2013 15:44:21 +0000
Message-ID: <50ED9E6502000078000B4220@nat28.tlf.novell.com>
References: <50EC099D.6020407@oracle.com>
 <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
 <1357652541.7989.179.camel@zakaz.uk.xensource.com>
 <50EC3DFD.8060206@oracle.com>
 <1357660834.12649.103.camel@dagon.hellion.org.uk>
 <50ED1EB3.3080605@oracle.com>
 <50ED4F1D02000078000B3F87@nat28.tlf.novell.com>
 <50ED6255.7020006@oracle.com>
 <50ED825802000078000B4113@nat28.tlf.novell.com> <50ED8ED3.8010007@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Ian Campbell" <Ian.Campbell@citrix.com>,
	<xen-devel@lists.xensource.com>, <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "Jason Luan" <luanjianhai@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:52556 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757971Ab3AIPoW (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:5:1>);
	Wed, 9 Jan 2013 10:44:22 -0500
In-Reply-To: <50ED8ED3.8010007@163.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 09.01.13 at 16:37, Jason Luan <luanjianhai@163.com> wrote:
> =E4=BA=8E 2013=E5=B9=B401=E6=9C=8809=E6=97=A5 21:44, Jan Beulich =E5=86=
=99=E9=81=93:
>>>>> On 09.01.13 at 13:28, jianhai luan <jianhai.luan@oracle.com> wrot=
e:
>>>>> +	switch (event) {
>>>>> +	case NETDEV_NOTIFY_PEERS:
>>>>> +		/* Notify frontend to Send gratuitous ARP */
>>>>> +		xenbus_switch_state(be->dev, XenbusStateInitialised);
>>>>> +		xenbus_switch_state(be->dev, );
>>>> This is the sort of change that clearly isn't acceptable, as I don=
't
>>>> think you have ways to check _all_ existing frontends for their
>>>> compatibility with this. A connected -> connected transition
>>>> might be acceptable (that was done in the block frontend too, for
>>>> implementing dynamic resize), but will likely need to be
>>>> accompanied by a frontend side patch to handle that (which so
>>>> far should be a no-op).
>>> The latest xen net-frontent driver have handled the condition. Stat=
e
>>> XenbusStateInitialised will do nothing,
>>> but change to XenbusStateConnected will trigger
>>> netdev_notify_peers(netdev) to send ARP.
>> Did you read my earlier reply carefully? You still only talk about
>> (upstream) Linux netfront, but this is not the only (possible)
>> frontend. You should not invoke state transitions that can -
>> even if only theoretically - blow up frontends. And afaict the
> I only want to notify xen-netfront. I don't know what is better way?
> To attainthegoal, i try to modify virtual interrupt, but the way is
> morecomplicated,modified and working. So, i give up the way.
> Would you like to give some suggestion about how to notify xen-netfro=
nt?
>> only thing you can safely assume frontends ought to tolerate
>> are transitions from Connected to Connected (or more
>> generally from one state to the same one, but the other
>> states aren't useful here, except maybe the Reconfigur* ones).
> Sorry for that. At the beginning the patch be applied in kernel 2.6.1=
8 to
> fixed one issue. Only XenbusStateInitialised and XenbusStateClosed ( =
Not
> Reconfigure* one) don't any thing, so i choose the XenbusStateInitial=
ised.
> Do you suggestion that i choose Reconfigure*?

I already said that I think that only a Connected->Connected
transition is to be considered here. Bringing up Reconfigur* was
just to point out that there are other states available that could
be used, but you'd first need to make sure that (a) they aren't
used for anything else and (b) frontends can reasonably be
expected to deal with (ignore) them when not originally aware
of them (as opposed to a Connected->Connected transition,
which all frontends ought to be able to deal with afaict).

Also, when you reply to earlier mails, could you - in order to make
the result readable - insert blank lines between the quoted text
and your responses, please?

Jan
