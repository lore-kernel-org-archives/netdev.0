From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 10:35:59 -0800
Message-ID: <5461058F.1020709@cumulusnetworks.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-11-git-send-email-jiri@resnulli.us> <546036A3.3010404@mojatatu.com> <CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com> <5460AF22.2040701@mojatatu.com> <5460E3D5.3000104@cumulusnetworks.com> <CAE4R7bARr8_=sS+6aezKDX0FfERUj8AD6eOGONKAeRd-g+9nDA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, nhorman@tuxdriver.com,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	vyasevic@redhat.com, Cong Wang <xiyou.wangcong@gmail.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Linville <linville@tuxdriver.com>, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Neil Jerram
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38754 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbaKJSgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 13:36:10 -0500
In-Reply-To: <CAE4R7bARr8_=sS+6aezKDX0FfERUj8AD6eOGONKAeRd-g+9nDA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/14, 9:36 AM, Scott Feldman wrote:
> On Mon, Nov 10, 2014 at 6:12 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> On 11/10/14, 4:27 AM, Jamal Hadi Salim wrote:
>>> On 11/10/14 03:46, Scott Feldman wrote:
>>>
>>>> IFLA_BRPORT_LEARNING is u8 attr and we're only using lower bit to turn
>>>> learning on/off.  Maybe we can use another bit to indicate learning to
>>>> be done in sw or hw.  I don't think adding another bit would break
>>>> existing iproute2.
>>>>
>>>> LEARNING_ENABLED    (1 << 0)
>>>> LEARNING_HW              (1 << 1)
>>>>
>>>> Would this work?
>>>>
>>> Yes to making it a bit. But:
>>> This is not *learning*. You are doing a *sync*.
>>> Those are two different things.
>>>
>>> Learning on/off exists today. It signals to the L2 whether you
>>> should learn or not.
>>> I like the way fdb_add/del work with a flag which says
>>> it is the software and/or offloaded version. Please keep that
>>> semantic.
>>> What you are doing above is letting the hardware learn then
>>> syncing to software. You need a different flag there. something
>>> like:
>>>
>>> SYNC_HW_FDB (1<<1)
>>>
>> And in any case, It seems like this policy should be per bridge or per
>> switch chip...or per fdb..
>> entry (like the original fdb_add/del) and not a "port" flag.. ?
> Per-port gives more flexibility, and it looks like we can extend
> existing IFLA_BRPORT_LEARNING without much trouble.
>
> I didn't follow the fdb_add/del comment?  Isn't an fdb entry
> port-specific by nature?  fdb entry = {port, mac, vlan} tuple.
yes it is, But if i remember correctly, the api (ndo op) could indicate 
offload to hw (or nic in this case)
by giving 'self'. And in those cases the netdev nic port represents the 
switch.
  (Will be nice to check and confirm this though).
