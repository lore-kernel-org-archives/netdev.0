From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 19:38:54 +0200
Message-ID: <20140920173854.GA1829@nanopsycho.orion>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com>
 <20140919154946.GH1980@nanopsycho.orion>
 <541CF75C.9030209@cumulusnetworks.com>
 <DDC24110-C3F5-470F-B9BE-1D1792415D1E@cumulusnetworks.com>
 <541D784B.6030302@cumulusnetworks.com>
 <DCCFAE52-F4BD-4877-A6FC-3C3AE180E871@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman <dborkman@redhat.com>,
	ogerlitz <ogerlitz@mellanox.com>, jesse <jesse@nicira.com>,
	pshelar <pshelar@nicira.com>, azhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>, dev@openvswitch.org,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com,
	Sergey Ryazan
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:47785 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755464AbaITRi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 13:38:57 -0400
Received: by mail-we0-f175.google.com with SMTP id u57so261054wes.6
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 10:38:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <DCCFAE52-F4BD-4877-A6FC-3C3AE180E871@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Sep 20, 2014 at 07:21:10PM CEST, sfeldma@cumulusnetworks.com wrote=
:
>
>On Sep 20, 2014, at 5:51 AM, Roopa Prabhu <roopa@cumulusnetworks.com> =
wrote:
>
>> On 9/20/14, 1:10 AM, Scott Feldman wrote:
>>> On Sep 19, 2014, at 8:41 PM, Roopa Prabhu <roopa@cumulusnetworks.co=
m>
>>>  wrote:
>>>=20
>>>=20
>>>> On 9/19/14, 8:49 AM, Jiri Pirko wrote:
>>>>=20
>>>>> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com
>>>>>  wrote:
>>>>>=20
>>>>>> On 09/19/14 09:49, Jiri Pirko wrote:
>>>>>>=20
>>>>>>> This patch exposes switchdev API using generic Netlink.
>>>>>>> Example userspace utility is here:
>>>>>>>=20
>>>>>>> https://github.com/jpirko/switchdev
>>>>>>>=20
>>>>>>>=20
>>>>>>>=20
>>>>>> Is this just a temporary test tool? Otherwise i dont see reason
>>>>>> for its existence (or the API that it feeds on).
>>>>>>=20
>>>>> Please read the conversation I had with Pravin and Jesse in v1 th=
read.
>>>>> Long story short they like to have the api separated from ovs dat=
apath
>>>>> so ovs daemon can use it to directly communicate with driver. Als=
o John
>>>>> Fastabend requested a way to work with driver flows without using=
 ovs ->
>>>>> that was the original reason I created switchdev genl api.
>>>>>=20
>>>>> Regarding the "sw" tool, yes it is for testing purposes now. ovs =
daemon
>>>>> will use directly switchdev genl api.
>>>>>=20
>>>>> I hope I cleared this out.
>>>>>=20
>>>> We already have all the needed rtnetlink kernel api and userspace =
tools around it to support all
>>>> switching asic features. ie, the rtnetlink api is the switchdev ap=
i. We can do l2, l3, acl's with it.
>>>> Its unclear to me why we need another new netlink api. Which will =
mean none of the existing tools to
>>>> create bridges etc will work on a switchdev.
>>>> Which seems like going in the direction exactly opposite to what w=
e had discussed earlier.
>>>>=20
>>> Existing rtnetlink isn=E2=80=99t available to swdev without some ki=
nd of snooping the echoes from the various kernel components (bridge, f=
ib, etc).  With swdev_flow, as Jiri has defined it, there is an additio=
nal conversion needed to bridge the gap (bad expression, I know) betwee=
n rtnetlink and swdev_flow.  This conversion happens in the kernel comp=
onents.  For example, the bridge module, still driven from userspace by=
 existing rtnetlink, will formulate the necessary swdev_flow insert/rem=
ove calls to the swdev driver such that HW will offload the fwd path.
>>>=20
>>> You have:
>>>     user -> rtnetlink -> kernel -> netlink echo -> [some process] -=
> [some driver] -> HW
>>>=20
>>>=20
>>> Jiri has:
>>>     user -> rtnetlink -> kernel -> swdev_* -> swdev driver -> HW
>>>=20
>>>=20
>> Keeping the goal to not change or not add a new userspace API in min=
d,
>> I have :
>>     user -> rtnetlink -> kernel -> ndo_op -> swdev driver  -> HW
>>=20
>
>Then you have the same as Jiri, for the traditional L2/L3 case.
>
>> Jiri has:
>>     user -> genl (newapi) -> kernel -> swdev_* -> swdev driver -> HW
>
>Jiri=E2=80=99s genl is for userspace apps that are talking rtnetlink, =
like OVS.  It=E2=80=99s not a substitute for rtnetlink, it=E2=80=99s an=
 alternative.  The complete picture is:

Not an alternative, an addition.

>
>user -> swdev genl -----
>                        \
>                         \
>                          -------> kernel -> ndo_swdev_* -> swdev driv=
er -> HW
>                         /
>                        /
>user -> rtnetlink ------

True is that, as Thomas pointed out, we can probably nest this into
rtnl_link messages. That might work.
