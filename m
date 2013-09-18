From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: Re: [PATCH v2 6/6] ipv6: Do route updating for redirect in ndisc
 layer
Date: Wed, 18 Sep 2013 19:57:53 +0800
Message-ID: <52399541.3060807@cn.fujitsu.com>
References: <52327F00.4040802@cn.fujitsu.com> <5232806B.6050601@cn.fujitsu.com> <20130917.202936.2080212548361553334.davem@davemloft.net> <20130918013903.GC8947@order.stressinduktion.org> <5239076A.4080406@cn.fujitsu.com> <20130918041337.GD8947@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54846 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752065Ab3IRL65 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 07:58:57 -0400
In-Reply-To: <20130918041337.GD8947@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B409=E6=9C=8818=E6=97=A5 12:13, Hannes Frederic So=
wa =E5=86=99=E9=81=93:
> On Wed, Sep 18, 2013 at 09:52:42AM +0800, Duan Jiong wrote:
>> =E4=BA=8E 2013=E5=B9=B409=E6=9C=8818=E6=97=A5 09:39, Hannes Frederic=
 Sowa =E5=86=99=E9=81=93:
>>> On Tue, Sep 17, 2013 at 08:29:36PM -0400, David Miller wrote:
>>>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>> Date: Fri, 13 Sep 2013 11:03:07 +0800
>>>>
>>>>> From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>>>
>>>>> Do the whole verification and route updating in ndisc
>>>>> lay and then just call into icmpv6_notify() to notify
>>>>> the upper protocols.
>>>>>
>>>>> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
>>>>
>>>> This is completely broken, and I believe your patch set fundamenta=
lly
>>>> is too.
>>>>
>>>> We absolutely _must_ handle the redirect at the socket level when
>>>> we are able to, otherwise we cannot specify the mark properly and
>>>> the mark is an essential part of the key used to find the correct
>>>> route to work with.
>>>>
>>>> I am not applying this patch series until you deal with this
>>>> deficiency.  I am not willing to consider changes which stop using=
 the
>>>> more precise keying information available from a socket.
>>>
>>> Oh, Duan, I am very sorry for not catching this earlier. We use the
>>> sk->mark to select the proper routing table where we clone the rt6_=
info into.
>>> And we only get that value out of the sockets. I missed that. We sh=
ould leave
>>> the redirect logic in the socket layer where it is possible.
>>>
>>> But parts of this series are still valid. We need to fix redirects =
for tunnels
>>> and I do think we can still simplify some code in the error handler=
s.
>>>
>>
>> I got it.
>=20
> I gave it a bit more thought:
>=20
> RFC 4861 8.3:
> "
>    Redirect messages apply to all flows that are being sent to a give=
n
>    destination.  That is, upon receipt of a Redirect for a Destinatio=
n
>    Address, all Destination Cache entries to that address should be
>    updated to use the specified next-hop, regardless of the contents =
of
>    the Flow Label field that appears in the Redirected Header option.
> "
>=20
> Especially because redirects also help in the on-link determination (=
same
> RFC, section 8), I changed my mind and am still in favour of updating=
 it
> in the ndisc layer. In my opinion we just have to consider all routin=
g
> tables and apply the update to every one which carries a valid next h=
op
> to the source of the redirect (under consideration of the destination=
).
>=20
> This will be important if we actually try to get linux to correctly
> implement the ipv6 subnet model (RFC 5942, Section 4 Rule 1). In that
> case we are not allowed to assume nodes on-link even if they would ma=
tch
> the same prefix as a locally configured address.
>=20

I think this need a little time to discuss with David Miller, so i will=
 send
the other patchs to fix redirects for tunnels and to fix the sk->sk_err
problems in udpv6_err()/rawv6_err().

Thanks,
  Duan
