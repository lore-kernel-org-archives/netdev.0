From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH 1/6] bridge: add support to parse multiple vlan info
 attributes in IFLA_AF_SPEC
Date: Mon, 29 Dec 2014 15:47:19 -0800
Message-ID: <CAE4R7bDiRd6WY7ry-vFCj2HgAFtxWznwJTX4vqxt_v5Q8LXdOg@mail.gmail.com>
References: <1419887132-7084-2-git-send-email-roopa@cumulusnetworks.com>
	<CAE4R7bAyWy83S-K_XtiRNJO2rZXtVpijPxqj_oq_sZqPKW-h-Q@mail.gmail.com>
	<54A1D157.1000002@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:41326 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbaL2XrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 18:47:21 -0500
Received: by mail-wi0-f177.google.com with SMTP id l15so23204671wiw.10
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 15:47:20 -0800 (PST)
In-Reply-To: <54A1D157.1000002@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 2:10 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 12/29/14, 1:40 PM, Scott Feldman wrote:
>>
>> On Mon, Dec 29, 2014 at 1:05 PM,  <roopa@cumulusnetworks.com> wrote:
>>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This patch changes bridge IFLA_AF_SPEC netlink attribute parser to
>>> look for more than one IFLA_BRIDGE_VLAN_INFO attribute. This allows
>>> userspace to pack more than one vlan in the setlink msg.
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> ---
>>>   net/bridge/br_netlink.c |   18 +++++++++---------
>>>   1 file changed, 9 insertions(+), 9 deletions(-)
>>>
>>> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
>>> index 9f5eb55..75971b1 100644
>>> --- a/net/bridge/br_netlink.c
>>> +++ b/net/bridge/br_netlink.c
>>> @@ -230,18 +230,18 @@ static int br_afspec(struct net_bridge *br,
>>>                       struct nlattr *af_spec,
>>>                       int cmd)
>>>   {
>>> -       struct nlattr *tb[IFLA_BRIDGE_MAX+1];
>>> +       struct bridge_vlan_info *vinfo;
>>>          int err = 0;
>>> +       struct nlattr *attr;
>>> +       int err = 0;
>>> +       int rem;
>>> +       u16 vid;
>>>
>>> -       err = nla_parse_nested(tb, IFLA_BRIDGE_MAX, af_spec,
>>> ifla_br_policy);
>>
>> Removing this call orphans ifla_br_policy...should ifla_br_policy be
>> removed?
>
>
> good question. Its a good place to see the type. In-fact userspace programs
> also copy the same policy to parse netlink attributes. hmmm..
> I would like to keep it if it does not throw a warning.

I don't know what the policy (sorry, no pun intended) on leaving dead
code.  I say remove it.
