From: Emil S Tantilov <emils.tantilov@gmail.com>
Subject: Re: [PATCH 1/4] IPv6: keep route for tentative address
Date: Fri, 21 May 2010 15:21:44 -0700
Message-ID: <AANLkTin3CfATS0-ePL5WUSiuq0seRCQgM6xc-YwxpPEy@mail.gmail.com>
References: <20100412154130.397252857@vyatta.com>
	 <20100412154255.641453741@vyatta.com>
	 <EA929A9653AAE14F841771FB1DE5A1365FE4FCE12C@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:36052 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292Ab0EUWVp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 18:21:45 -0400
Received: by qyk1 with SMTP id 1so2083627qyk.5
        for <netdev@vger.kernel.org>; Fri, 21 May 2010 15:21:45 -0700 (PDT)
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365FE4FCE12C@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 12, 2010 at 1:17 PM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:
> Stephen Hemminger wrote:
>> Recent changes preserve IPv6 address when link goes down (good).
>> But would cause address to point to dead dst entry (bad).
>> The simplest fix is to just not delete route if address is
>> being held for later use.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>>
>> --- a/net/ipv6/addrconf.c =C2=A0 =C2=A0 2010-04-11 12:19:37.93808219=
0 -0700
>> +++ b/net/ipv6/addrconf.c =C2=A0 =C2=A0 2010-04-11 12:25:05.34930907=
4 -0700
>> @@ -4046,7 +4046,8 @@ static void __ipv6_ifa_notify(int event,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 addrconf_leave_anycast(ifp);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 addrconf_leave_soli=
ct(ifp->idev, &ifp->addr);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 dst_hold(&ifp->rt->=
u.dst);
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ip6_del_rt(ifp->rt))
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (ifp->dead && ip6_del=
_rt(ifp->rt))
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 dst_free(&ifp->rt->u.dst);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 break;
>> =C2=A0 =C2=A0 =C2=A0 }
>
> Stephen,
>
> With these series of patches (1-4) applied I am no longer seeing the
> hangs and warnings associated with ipv6. I ran few rounds of
> tests with resetting the interface and loading/unloading modules.

Looks like these patches did not make it into net-2.6 and the issue can=
 be seen
in the latest stable 2.6.34.

Any chance that the patches can be pushed to 2.6.34-stable?

Thanks,
Emil
