From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC:  Allow 'ip' to run in daemon mode?
Date: Wed, 30 Jun 2010 09:01:26 -0700
Message-ID: <4C2B6A56.9040108@candelatech.com>
References: <jqfv3n22gfvc4e8j9qgxednu.1277881246865@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37365 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932197Ab0F3QBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 12:01:31 -0400
In-Reply-To: <jqfv3n22gfvc4e8j9qgxednu.1277881246865@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/30/2010 12:00 AM, Stephen Hemminger wrote:
> write a new service rather than bloating the existing code or just us=
e netlink or libnl

I find netlink code a pain to deal with, so I'd like to leverage
existing and ongoing support in iproute.

Would you at least consider the changes in 1) and 2)
so that the new project can continue to use iproute as upstream
w/out significant merge issues?  Those changes shouldn't
significantly add to the code, I believe.

Thanks,
Ben

>
> Ben Greear<greearb@candelatech.com>  wrote:
>
>> I'm considering modifying 'ip' to be able to run in daemon
>> mode so that I can do lots of IP commands without having to
>> pay the startup cost of iproute.
>>
>> The -batch option almost works, but it's hard to programatically
>> figure out failure codes.
>>
>> I'm thinking about making these changes:
>>
>> 1)  Move all of the error printing code into common methods (basical=
ly,
>>     wrap printf).  In daemon mode this text can be sent back to the
>>     calling process, and in normal mode, it will be printed to stdou=
t/stderr
>>     as it is currently.
>>
>> 2)  Remove all or most calls to 'exit' and instead return error code=
s
>>     to the calling logic.
>>
>> 3)  Add ability to listen on a unix socket for commands, basically t=
reat
>>     them just like batch commands, one command per packet.
>>
>> 4)  Return well formatted error code and text response to calling pr=
ocess
>>     over the unix socket, maybe something like:
>>
>> RV: [errno or equiv, zero for success]\n
>> CMD: [ command string this relates to ]\n
>> [ Optional free form text ]
>>
>>
>> Does something like this have any chance of upstream inclusion?
>>
>> Thanks,
>> Ben
>>
>> --
>> Ben Greear<greearb@candelatech.com>
>> Candela Technologies Inc  http://www.candelatech.com
> N=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BDr=EF=BF=BD=EF=BF=BDy=EF=
=BF=BD=EF=BF=BD=EF=BF=BDb=EF=BF=BDX=EF=BF=BD=EF=BF=BD=C7=A7v=EF=BF=BD^=EF=
=BF=BD)=DE=BA{.n=EF=BF=BD+=EF=BF=BD=EF=BF=BD=EF=BF=BDz=EF=BF=BD^=EF=BF=BD=
)=EF=BF=BD=EF=BF=BD=EF=BF=BDw*=1Fjg=EF=BF=BD=EF=BF=BD=EF=BF=BD=1E=EF=BF=
=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=BD=DD=A2j/=EF=BF=BD=EF=BF=BD=EF=BF=
=BDz=EF=BF=BD=DE=96=EF=BF=BD=EF=BF=BD2=EF=BF=BD=DE=99=EF=BF=BD=EF=BF=BD=
=EF=BF=BD&=EF=BF=BD)=DF=A1=EF=BF=BDa=EF=BF=BD=EF=BF=BD=7F=EF=BF=BD=EF=BF=
=BD=1E=EF=BF=BDG=EF=BF=BD=EF=BF=BD=EF=BF=BDh=EF=BF=BD=0F=EF=BF=BDj:+v=EF=
=BF=BD=EF=BF=BD=EF=BF=BDw=EF=BF=BD=D9=A5


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
