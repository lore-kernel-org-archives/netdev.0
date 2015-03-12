From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE
 state
Date: Thu, 12 Mar 2015 19:16:32 +0900
Message-ID: <55016780.8060000@miraclelinux.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com> <55013BD4.2080605@windriver.com> <5501518D.2070405@miraclelinux.com> <B35CF589-BE57-4F34-9CC2-A657F3DCF264@emagii.com> <55015C3E.9060009@miraclelinux.com> <CA716BBF-6431-44FC-ADA1-2F87402001F5@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hideaki.yoshifuji@miraclelinux.com,
	yzhu1 <Yanjun.Zhu@windriver.com>,
	"brian.haley@hp.com" <brian.haley@hp.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"alexandre.dietsch@windriver.com" <alexandre.dietsch@windriver.com>,
	"clinton.slabbert@windriver.com" <clinton.slabbert@windriver.com>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ulf.samuelsson@ericsson.com" <ulf.samuelsson@ericsson.com>,
	"YOSHIFUJI Hideaki (USAGI Project)" <yoshfuji@linux-ipv6.org>
To: Ulf samuelsson <netdev@emagii.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og103.obsmtp.com ([64.18.2.159]:40571 "HELO
	exprod7og103.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753685AbbCLKQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 06:16:37 -0400
Received: by mail-pd0-f170.google.com with SMTP id fl12so19000627pdb.5
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 03:16:36 -0700 (PDT)
In-Reply-To: <CA716BBF-6431-44FC-ADA1-2F87402001F5@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ulf samuelsson wrote:
> If you want to send 3 unicasts followed by 3 broadcast,
> you have to set mcast_solicit to 6.
> This means you will send 6 broadcasts in incomplete state.
>
> I think the following configuration is wanted:
>
> Incomplete state: send 3 broadcast
> Probe state: send 3 unicast, followed by 3 broadcast then goto STALE =
OR
>                       Send 3 unicast, then go to STALE

I pointed out that we deal with nodes that won't reply against
unicast ARP/NDP via existing knobs.

If you really want such configuration, it is better to split
mcast_solicit.  "bcast_solicit" does not sound good to me.
You could say "probe_mcast_solicit".

--yoshfuji

>
> Best Regards
> Ulf Samuelsson
> ulf@emagii.com
> +46  (722) 427 437
>
>
>> 12 mar 2015 kl. 10:28 skrev YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=
=B1=E6=98=8E  <hideaki.yoshifuji@miraclelinux.com>:
>>
>> Hi,
>>
>> Ulf samuelsson wrote:
>>> That also means that you increase the number of broadcasts in incom=
plete state.
>>> Is that really desirable?
>>
>> In NUD_INCOMPLETE state, neighbour subsystem *skips* sending unicast=
 probes
>> and send multicast probes mcast_solicit times. If you do not increas=
e
>> the number of mcast_solicit, the number of multicast probes in
>> NUD_INCOMPLETE will not increased.
>>
>> --yoshfuji
>>
>>>
>>> Best Regards
>>> Ulf Samuelsson
>>> ulf@emagii.com
>>> +46  (722) 427 437
>>>
>>>
>>>> 12 mar 2015 kl. 09:42 skrev YOSHIFUJI Hideaki <hideaki.yoshifuji@m=
iraclelinux.com>:
>>>>
>>>> Hello.
>>>>
>>>> yzhu1 wrote:
>>>>> The state machine is in the attachment.
>>>>>
>>>>> Best Regards!
>>>>> Zhu Yanjun
>>>>>> On 03/12/2015 02:58 PM, Zhu Yanjun wrote:
>>>>>> V2:
>>>>>>    set ARP_PROBE_BCAST default N.
>>>>>>
>>>>>> V1:
>>>>>>    Have a problem with an HP router at a certain location, which
>>>>>>    is configured to only answer to broadcast ARP requests.
>>>>>>    That cannot be changed.
>>>>>>
>>>>>>    The first ARP request the kernel sends out, is a broadcast re=
quest,
>>>>>>    which is fine, but after the reply, the kernel sends unicast =
requests,
>>>>>>    which will not get any replies.
>>>>>>
>>>>>>    The ARP entry will after some time enter STALE state,
>>>>>>    and if nothing is done it will time out, and be removed.
>>>>>>    This process takes to long, and I have been told that it is
>>>>>>    difficult to makes changes that will eventually remove it.
>>>>>>
>>>>>>    Have tried to change the state from STALE to INCOMPLETE, whic=
h failed,
>>>>>>    and then tried to change the state to PROBE which also failed=
=2E
>>>>>>
>>>>>>    The stack is only sending out unicasts, and never broadcast.
>>>>>>    Is there any way to get the stack to send out a broadcast ARP
>>>>>>    without having to wait for the entry to be removed?
>>>>
>>>> Neighbour subsystem will send multicast probes after unicast
>>>> probes in NUD_PROBE state if mcast_solicit is more than
>>>> ucast_solicit.  Try setting net.ipv4.neigh.*.ucast_solicit to
>>>> the value less than net.ipv4.neigh.*.mcast_solicit, please?
>>>> e.g.
>>>>
>>>> net.ipv4.neigh.eth0.mcast_solicit =3D 3
>>>> net.ipv4.neigh.eth0.ucast_solicit =3D 1
>>>>
>>>> --yoshfuji
>>>>
>>>>
>>>>>>
>>>>>>    I think the recommended behaviour in IPv6 is to send out 3 un=
icasts
>>>>>>    and if all fails, to send out broadcasts.
>>>>>>
>>>>>> Zhu Yanjun (1):
>>>>>>    neighbour: Support broadcast ARP in neighbor PROPE state
>>>>>>
>>>>>>   include/net/neighbour.h        |  7 ++++++
>>>>>>   include/uapi/linux/neighbour.h |  6 +++++
>>>>>>   include/uapi/linux/sysctl.h    |  3 +++
>>>>>>   kernel/sysctl_binary.c         |  3 +++
>>>>>>   net/core/neighbour.c           | 44 ++++++++++++++++++++++++++=
+++---
>>>>>>   net/ipv4/Kconfig               | 57 ++++++++++++++++++++++++++=
++++++++++++++++
>>>>>>   net/ipv4/arp.c                 |  7 ++++--
>>>>>>   7 files changed, 121 insertions(+), 6 deletions(-)
>>>>
>>>> --
>>>> Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
>>>> Technical Division, MIRACLE LINUX CORPORATION
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" =
in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>> --
>> =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinux=
=2Ecom>
>> =E3=83=9F=E3=83=A9=E3=82=AF=E3=83=AB=E3=83=BB=E3=83=AA=E3=83=8A=E3=83=
=83=E3=82=AF=E3=82=B9=E6=A0=AA=E5=BC=8F=E4=BC=9A=E7=A4=BE =E6=8A=80=E8=A1=
=93=E6=9C=AC=E9=83=A8 =E3=82=B5=E3=83=9D=E3=83=BC=E3=83=88=E9=83=A8
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
