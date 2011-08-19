From: krbmit siso <krbmit@gmail.com>
Subject: Re: protect raw sockets
Date: Fri, 19 Aug 2011 12:13:01 +0530
Message-ID: <CABjs8yU_+7asT+=FS5CSsZrmkwADUjpVr7+kP2WGcPtsCdFWag@mail.gmail.com>
References: <A2354B6A9F807641B21EEABD666ECEEA011AFCE2@XMB-BGL-416.cisco.com>
	<CABjs8yWMgyyPHC1Nfgs2TZ1ixN7Khq0OimEhUhTs-Ux_9LAx5g@mail.gmail.com>
	<CABjs8yVOgKBrF2dMopzPmsfouWz5WHCAZCqjG3nY76CaqTFRLw@mail.gmail.com>
	<4E4DF979.5030708@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ipsec-tools-users@lists.sourceforge.net,
	ipsec-tools-devel@lists.sourceforge.net,
	ikev2-devel@lists.sourceforge.net
To: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:43273 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab1HSGnD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 02:43:03 -0400
Received: by gxk21 with SMTP id 21so2008758gxk.19
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2011 23:43:01 -0700 (PDT)
In-Reply-To: <4E4DF979.5030708@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Timo ,
You are absolutely right, I am using it for traffic generator but,
i want it with ESP , so i want to make the best use of underlying kerne=
l
XFRM functionality . It can be provided has an option
in the kernel like eg ..CONFIG_SECURE_RAW for applying IPsec
policy .

Regards
Naveen

2011/8/19 Timo Ter=E4s <timo.teras@iki.fi>:
> On 08/18/2011 06:01 PM, krbmit siso wrote:
>> After adding the below code in net/ipv4/raw.c in function raw_send_h=
drinc()
>> I am able to see packet sent using RAW_SOCKET getting protected .
>>
>> Please =A0let me know how can it be done better and provide it has a=
 feature
>> , so that others can also use it =A0if =A0packet sent using RAW_SOCK=
ET
>> needs to be protected.
>
> Raw sockets are raw sockets. They are used to send out network traffi=
c
> that was captured earlier, or to generate test traffic. I don't think
> it makes any sense to apply XFRM policies to them: it might break the
> usage this API was intended for. The whole purpose of raw sockets is =
to
> bypass kernel side extra handling.
>
> To generate IPsec protected stuff use the normal APIs: regular UDP/TC=
P
> sockets.
>
> The same applies for sending/receiving IKE packets. You need regular =
UDP
> socket with IPsec bypass policy.
>
> What's your point in trying to use raw sockets? You should not need t=
o
> use them unless you are implementing a packet capturer or a network
> traffic generator.
>
> - Timo
>
