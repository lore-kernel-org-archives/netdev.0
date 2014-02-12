From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Wed, 12 Feb 2014 10:32:49 +0100
Message-ID: <52FB3FC1.8080603@6wind.com>
References: <1391811158-11433-1-git-send-email-pshelar@nicira.com>	<20140207222840.GD16198@order.stressinduktion.org>	<CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com>	<20140208005843.GE16198@order.stressinduktion.org>	<CALnjE+qiRbLWBJyhig7DFETRLRgAZHqJqUEYGVuJ6nXc7cPguw@mail.gmail.com>	<20140211021150.GB11150@order.stressinduktion.org> <CALnjE+r5zUs0GKUESoum2YumjbfU2XKhDjjcoWUv2D8yiGEYkA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:44388 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbaBLJcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 04:32:52 -0500
Received: by mail-ee0-f51.google.com with SMTP id b57so4206232eek.10
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 01:32:51 -0800 (PST)
In-Reply-To: <CALnjE+r5zUs0GKUESoum2YumjbfU2XKhDjjcoWUv2D8yiGEYkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/02/2014 05:26, Pravin Shelar a =E9crit :
> On Mon, Feb 10, 2014 at 6:11 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On Mon, Feb 10, 2014 at 01:00:14PM -0800, Pravin Shelar wrote:
>>> On Fri, Feb 7, 2014 at 4:58 PM, Hannes Frederic Sowa
>>> <hannes@stressinduktion.org> wrote:
>>>> May I know because of wich vport, vxlan or gre, you did this chang=
e?
>>>>
>>> It affects both gre and vxlan.
>>
>> Ok, thanks.
>>
>>>> I am feeling a bit uncomfortable handling remote and local packets=
 that
>>>> differently on lower tunnel output (local_df is mostly set on loca=
lly
>>>> originating packets).
>>>
>>> For ip traffic it make sense to turn on local_df only for local
>>> traffic, since for remote case we can send icmp (frag-needed) back =
to
>>> source. No such thing exist for OVS tunnels. ICMP packet are not
>>> returned to source for the tunnels. That is why to be on safe side,
>>> local_df is turned on for tunnels in OVS.
>>
>> I have a proposal:
>>
>> I don't like it that much because of the many arguments. But I curre=
ntly
>> don't see another easy solution. Maybe we should make bool xnet an e=
num and
>> test with bitops?
>>
>> I left the clearing of local_df in skb_scrub_packet as we need it fo=
r the
>> dev_forward_skb case and it should be done that in any case.
>>
>> This diff is slightly compile tested. ;)
>>
>> I can test and make proper submit if you agree.
>>
>> What do you think?
>>
>
> I am not sure why the caller can not just set skb->local_df before
> calling iptunnel_xmit() rather than passing extra arg to this
> function?
> There are not that many caller of this function.
The benefit is that it ensures that future callers will think about thi=
s point
;-)

Steffen is reworking vti code and will use skb_scrub_packet(), I CC'ed =
him in
case he has some comment about this change.


Regards,
Nicolas
