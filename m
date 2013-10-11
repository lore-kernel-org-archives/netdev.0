From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net] {xfrm, sctp} Stick to software crc32 even if hardware
 is capable of that
Date: Fri, 11 Oct 2013 15:02:35 +0800
Message-ID: <5257A28B.8000507@windriver.com>
References: <1381384296-1821-1-git-send-email-fan.du@windriver.com> <20131010131116.GA16147@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <vyasevich@gmail.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>, <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63786 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756482Ab3JKHDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 03:03:52 -0400
In-Reply-To: <20131010131116.GA16147@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 21:11, Neil Horman wrote:
> On Thu, Oct 10, 2013 at 01:51:36PM +0800, Fan Du wrote:
>> igb/ixgbe have hardware sctp checksum support, when this feature is =
enabled
>> and also IPsec is armed to protect sctp traffic, ugly things happene=
d as
>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum ev=
ery thing
>> up and pack the 16bits result in the checksum field). The result is =
fail
>> establishment of sctp communication.
>>
> Shouldn't this be fixed in the xfrm code then?  E.g. check the device=
 features
> for SCTP checksum offloading and and skip the checksum during xfrm ou=
tput if its
> available?

sigh... same as my first thought.
However why should xfrm_output check whether the skb is a SCTP one as w=
ell as whether
the associated dev is able to do hw SCTP crc32-c checksum in the first =
place, and then
call SCTP crc checksum value API to write the correct checksum *after* =
this skb has
leaven SCTP layer???

The checksum operation in xfrm_ouput fits TCP/UDP/IP layer checksum sem=
antics, e.g.
calculate 16bits value by sum almost everything up. Make a SCTP specifi=
c exception
in this common path sound wired, as the fix can be done in SCTP codes e=
asily with
minimum changes, so not any bit of consequence for non-SCTP traffic.

And If you/Vlad insist to do so as well as no objection from Steffen/Da=
vid, I'm
happy to send this revised version as your suggested.

Anyway, I should have separated this patch for two which makes the issu=
es more clear
for you and Vlad to review.

> Or am I missing something?
> Neil
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
