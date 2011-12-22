From: Chris Boot <bootc@bootc.net>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in ipv6_select_ident
Date: Thu, 22 Dec 2011 10:04:34 +0000
Message-ID: <4EF300B2.3050903@bootc.net>
References: <4EF200BB.7000209@bootc.net>   <1324484956.2301.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <4EF2117F.6000803@bootc.net>   <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>   <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop>  <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>  <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net> <1324528656.2621.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1324528656.2621.19.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/12/2011 04:37, Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 23:12 +0000, Chris Boot a =C3=
=A9crit :
>> On 21 Dec 2011, at 21:58, Chris Boot wrote:
>>
>>> On 21/12/2011 20:52, Eric Dumazet wrote:
>>>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 21:28 +0100, Eric Dumazet=
 a =C3=A9crit :
>>>>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 20:05 +0000, Chris Boot =
a =C3=A9crit :
>>>>>> On 21/12/2011 18:00, Eric Dumazet wrote:
>>>>>>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 18:36 +0100, Eric Duma=
zet a =C3=A9crit :
>>>>>>>
>>>>>>>> Good point, thats a different problem then, since 3.1 is not s=
upposed to
>>>>>>>> have this bug.
>>>>>>>>
>>>>>>>> It seems rt->rt6i_peer points to invalid memory in your crash.
>>>>>>>>
>>>>>>>> (RBX=3D00000000000001f4)
>>>>>>>>
>>>>>>>> 8b 83 a4 00 00 00       mov    0xa4(%rbx),%eax    p->refcnt
>>>>>>>> 1f4+a4 ->    CR2=3D0000000000000298
>>>>>>>>
>>>>>>> It would help if you can confirm latest linux tree can reproduc=
e the
>>>>>>> bug.
>>>>>> Hi Eric,
>>>>>>
>>>>>> I just built a v3.2-rc6-140-gb9e26df with the same config as the=
 Debian
>>>>>> 3.1.0 kernel. I can reproduce the bug just as easily with this k=
ernel as
>>>>>> with the Debian kernel. Unfortunately I wasn't able to get an en=
tire
>>>>>> trace, for some reason it didn't appear to be printed to the ser=
ial port
>>>>>> and hung after the (long) list of loaded kernel modules. The cra=
sh
>>>>>> happens at the same offset:
>>>>>>
>>>>> Thanks !
>>>>>
>>>>> Oh well, br_netfilter fake_rtable strikes again.
>>>>>
>>>>> I'll cook a patch in a couple of minutes...
>>>>>
>>>> Could you try following patch ?
>>>>
>>>> [snip]
>>> Eric,
>>>
>>> It looks good! The rsync that caused the crash real quick hasn't do=
ne it at all with the patch applied. I'll keep testing it of course, bu=
t I think that's done it.
>> No, sorry, false hope. The following does look rather different howe=
ver:
>>
>> [snip]
> This one is different, its not IPv6 related but IPv4 :
>
> fake_dst_ops lacks a .mtu() field
>
> Bug added in commit 618f9bc74a039da76 (net: Move mtu handling down to
> the protocol depended handlers)
>
> Here is an updated patch, thanks again !
>
> [snip]

Eric,

So far so good. I've had this running for several hours this morning=20
with more of the prodding that would normally have crashed it, both IPv=
4=20
and IPv6, and it's holding up well.

Thanks again,
Chris

--=20
Chris Boot
bootc@bootc.net
