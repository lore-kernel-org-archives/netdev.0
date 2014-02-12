From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] net: Clear local_df only if crossing namespace.
Date: Wed, 12 Feb 2014 09:05:55 -0800
Message-ID: <CALnjE+ogMJ=axPo6Xq3a7xO2W5fLY1utwcACRdeoCPgYv4EQsg@mail.gmail.com>
References: <1391811158-11433-1-git-send-email-pshelar@nicira.com>
	<20140207222840.GD16198@order.stressinduktion.org>
	<CALnjE+pbcbENWjQcE8T0QLa=d0iia3EBBVJz-sGVzAZbsQarLQ@mail.gmail.com>
	<20140208005843.GE16198@order.stressinduktion.org>
	<CALnjE+qiRbLWBJyhig7DFETRLRgAZHqJqUEYGVuJ6nXc7cPguw@mail.gmail.com>
	<20140211021150.GB11150@order.stressinduktion.org>
	<CALnjE+r5zUs0GKUESoum2YumjbfU2XKhDjjcoWUv2D8yiGEYkA@mail.gmail.com>
	<52FB3FC1.8080603@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog027.obsmtp.com ([74.125.150.94]:59580 "HELO
	na6sys009bog027.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751584AbaBLRF5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 12:05:57 -0500
Received: by mail-vc0-f169.google.com with SMTP id hq11so7421739vcb.0
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 09:05:55 -0800 (PST)
In-Reply-To: <52FB3FC1.8080603@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 12, 2014 at 1:32 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 12/02/2014 05:26, Pravin Shelar a =E9crit :
>
>> On Mon, Feb 10, 2014 at 6:11 PM, Hannes Frederic Sowa
>> <hannes@stressinduktion.org> wrote:
>>>
>>> On Mon, Feb 10, 2014 at 01:00:14PM -0800, Pravin Shelar wrote:
>>>>
>>>> On Fri, Feb 7, 2014 at 4:58 PM, Hannes Frederic Sowa
>>>> <hannes@stressinduktion.org> wrote:
>>>>>
>>>>> May I know because of wich vport, vxlan or gre, you did this chan=
ge?
>>>>>
>>>> It affects both gre and vxlan.
>>>
>>>
>>> Ok, thanks.
>>>
>>>>> I am feeling a bit uncomfortable handling remote and local packet=
s that
>>>>> differently on lower tunnel output (local_df is mostly set on loc=
ally
>>>>> originating packets).
>>>>
>>>>
>>>> For ip traffic it make sense to turn on local_df only for local
>>>> traffic, since for remote case we can send icmp (frag-needed) back=
 to
>>>> source. No such thing exist for OVS tunnels. ICMP packet are not
>>>> returned to source for the tunnels. That is why to be on safe side=
,
>>>> local_df is turned on for tunnels in OVS.
>>>
>>>
>>> I have a proposal:
>>>
>>> I don't like it that much because of the many arguments. But I curr=
ently
>>> don't see another easy solution. Maybe we should make bool xnet an =
enum
>>> and
>>> test with bitops?
>>>
>>> I left the clearing of local_df in skb_scrub_packet as we need it f=
or the
>>> dev_forward_skb case and it should be done that in any case.
>>>
>>> This diff is slightly compile tested. ;)
>>>
>>> I can test and make proper submit if you agree.
>>>
>>> What do you think?
>>>
>>
>> I am not sure why the caller can not just set skb->local_df before
>> calling iptunnel_xmit() rather than passing extra arg to this
>> function?
>> There are not that many caller of this function.
>
> The benefit is that it ensures that future callers will think about t=
his
> point
> ;-)
>

But that add extra test cases in fast path.
=46or example OVS we can not reset skb->mark in skb_scrub_packet(). I a=
m
going to send patch for that too. Do you think I should add another
argument for skb-mark clear too ?
We can not make code every piece of code future proof. thats why we
have review process.
