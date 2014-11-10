From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [patch net-next v2 10/10] rocker: implement L2 bridge offloading
Date: Mon, 10 Nov 2014 09:47:49 -1000
Message-ID: <CAE4R7bDQesnq8kDFsUqiY0+H1SnUHPSJACLMgFc9eX8chjoxKA@mail.gmail.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us>
	<1415530280-9190-11-git-send-email-jiri@resnulli.us>
	<546036A3.3010404@mojatatu.com>
	<CAE4R7bCdfn6rzvY5J5d_aj=eNKoT00iEphGJMnQOWy=WeLePTw@mail.gmail.com>
	<5460AF22.2040701@mojatatu.com>
	<5460E3D5.3000104@cumulusnetworks.com>
	<CAE4R7bARr8_=sS+6aezKDX0FfERUj8AD6eOGONKAeRd-g+9nDA@mail.gmail.com>
	<5461058F.1020709@cumulusnetworks.com>
	<54611192.5080606@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>,
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
	ebiederm@xmission.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org,
	Alexei Starovoitov <alexei.starovoitov@gm
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:56997 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbaKJTrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 14:47:51 -0500
Received: by mail-wi0-f177.google.com with SMTP id ex7so11677526wid.4
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 11:47:49 -0800 (PST)
In-Reply-To: <54611192.5080606@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 10, 2014 at 9:27 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 11/10/14 13:35, Roopa Prabhu wrote:
>>
>> On 11/10/14, 9:36 AM, Scott Feldman wrote:
>>>
>>> On Mon, Nov 10, 2014 at 6:12 AM, Roopa Prabhu
>>> <roopa@cumulusnetworks.com> wrote:
>>>>
>>>> On 11/10/14, 4:27 AM, Jamal Hadi Salim wrote:
>>>>>
>>>>> On 11/10/14 03:46, Scott Feldman wrote:
>>
>>
>> yes it is, But if i remember correctly, the api (ndo op) could indicate
>> offload to hw (or nic in this case)
>> by giving 'self'. And in those cases the netdev nic port represents the
>> switch.
>>   (Will be nice to check and confirm this though).
>
>
> No, you are correct. You select to add to the bridge fdb or/and via
> the underlying brport fdb.


For swdev, I don't care for the model where each port has an fdb and
the bridge has an fdb.  The bridge's fdb lookup/learning/fwding is
what we're offloading to HW, so it makes more sense from the driver
and to the user to use one fdb, the bridge's fdb.  So user types
"bridge fdb show" and static fdbs installed on the bridge and learned
fdbs synced from HW are represented.  One table.

I view the existing ndo_fdb_add/del ops useful for devices working
standalone without the bridge driver that have some HW fwding
capabilities and need to manage their own fdb.  For devices under
bridge, let's use the bridge's fdb, at least for swdev.

Does this make sense?  I hate to use a lot of "I"s in my sentences,
but looks like I did exactly that in above, so take this as an
opinion, within the scope of swdev.

-scott
