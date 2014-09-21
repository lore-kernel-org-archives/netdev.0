From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Sat, 20 Sep 2014 18:30:33 -0700
Message-ID: <541E2A39.8010306@cumulusnetworks.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us> <1411134590-4586-9-git-send-email-jiri@resnulli.us> <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion> <541CF75C.9030209@cumulusnetworks.com> <DDC24110-C3F5-470F-B9BE-1D1792415D1E@cumulusnetworks.com> <541D784B.6030302@cumulusnetworks.com> <DCCFAE52-F4BD-4877-A6FC-3C3AE180E871@cumulusnetworks.com> <20140920173854.GA1829@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Scott Feldman <sfeldma@cumulusnetworks.com>,
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
	Sergey Rya
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:40228 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751425AbaIUBao convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 21:30:44 -0400
In-Reply-To: <20140920173854.GA1829@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/14, 10:38 AM, Jiri Pirko wrote:
> Sat, Sep 20, 2014 at 07:21:10PM CEST, sfeldma@cumulusnetworks.com wro=
te:
>> On Sep 20, 2014, at 5:51 AM, Roopa Prabhu <roopa@cumulusnetworks.com=
> wrote:
>>
>>> On 9/20/14, 1:10 AM, Scott Feldman wrote:
>>>> On Sep 19, 2014, at 8:41 PM, Roopa Prabhu <roopa@cumulusnetworks.c=
om>
>>>>   wrote:
>>>>
>>>>
>>>>> On 9/19/14, 8:49 AM, Jiri Pirko wrote:
>>>>>
>>>>>> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs@mojatatu.com
>>>>>>   wrote:
>>>>>>
>>>>>>> On 09/19/14 09:49, Jiri Pirko wrote:
>>>>>>>
>>>>>>>> This patch exposes switchdev API using generic Netlink.
>>>>>>>> Example userspace utility is here:
>>>>>>>>
>>>>>>>> https://github.com/jpirko/switchdev
>>>>>>>>
>>>>>>>>
>>>>>>>>
>>>>>>> Is this just a temporary test tool? Otherwise i dont see reason
>>>>>>> for its existence (or the API that it feeds on).
>>>>>>>
>>>>>> Please read the conversation I had with Pravin and Jesse in v1 t=
hread.
>>>>>> Long story short they like to have the api separated from ovs da=
tapath
>>>>>> so ovs daemon can use it to directly communicate with driver. Al=
so John
>>>>>> Fastabend requested a way to work with driver flows without usin=
g ovs ->
>>>>>> that was the original reason I created switchdev genl api.
>>>>>>
>>>>>> Regarding the "sw" tool, yes it is for testing purposes now. ovs=
 daemon
>>>>>> will use directly switchdev genl api.
>>>>>>
>>>>>> I hope I cleared this out.
>>>>>>
>>>>> We already have all the needed rtnetlink kernel api and userspace=
 tools around it to support all
>>>>> switching asic features. ie, the rtnetlink api is the switchdev a=
pi. We can do l2, l3, acl's with it.
>>>>> Its unclear to me why we need another new netlink api. Which will=
 mean none of the existing tools to
>>>>> create bridges etc will work on a switchdev.
>>>>> Which seems like going in the direction exactly opposite to what =
we had discussed earlier.
>>>>>
>>>> Existing rtnetlink isn=E2=80=99t available to swdev without some k=
ind of snooping the echoes from the various kernel components (bridge, =
fib, etc).  With swdev_flow, as Jiri has defined it, there is an additi=
onal conversion needed to bridge the gap (bad expression, I know) betwe=
en rtnetlink and swdev_flow.  This conversion happens in the kernel com=
ponents.  For example, the bridge module, still driven from userspace b=
y existing rtnetlink, will formulate the necessary swdev_flow insert/re=
move calls to the swdev driver such that HW will offload the fwd path.
>>>>
>>>> You have:
>>>>      user -> rtnetlink -> kernel -> netlink echo -> [some process]=
 -> [some driver] -> HW
>>>>
>>>>
>>>> Jiri has:
>>>>      user -> rtnetlink -> kernel -> swdev_* -> swdev driver -> HW
>>>>
>>>>
>>> Keeping the goal to not change or not add a new userspace API in mi=
nd,
>>> I have :
>>>      user -> rtnetlink -> kernel -> ndo_op -> swdev driver  -> HW
>>>
>> Then you have the same as Jiri, for the traditional L2/L3 case.
>>
>>> Jiri has:
>>>      user -> genl (newapi) -> kernel -> swdev_* -> swdev driver -> =
HW
>> Jiri=E2=80=99s genl is for userspace apps that are talking rtnetlink=
, like OVS.  It=E2=80=99s not a substitute for rtnetlink, it=E2=80=99s =
an alternative.  The complete picture is:
> Not an alternative, an addition.
>
>> user -> swdev genl -----
>>                         \
>>                          \
>>                           -------> kernel -> ndo_swdev_* -> swdev dr=
iver -> HW
>>                          /
>>                         /
>> user -> rtnetlink ------
> True is that, as Thomas pointed out, we can probably nest this into
> rtnl_link messages. That might work.
That's the thing i was hinting as well. You can extend the existing=20
infrastructure/api  instead of adding a new one.
