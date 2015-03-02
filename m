From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 1/2] net: dsa: integrate with SWITCHDEV for HW bridging
Date: Mon, 02 Mar 2015 09:16:32 -0800
Message-ID: <54F49AF0.6060305@roeck-us.net>
References: <54EA8E7C.90401@roeck-us.net> <20150223031447.GA19267@lunn.ch> <54EAA767.6060105@roeck-us.net> <20150223042220.GA20063@lunn.ch> <54EAAEBC.6080609@roeck-us.net> <CAGVrzcYnuV6raXSrAETctwX5dwX3S=2-=ySewCFdx=iM7bPaDg@mail.gmail.com> <20150223133454.GB23581@lunn.ch> <54EB37C7.3090209@roeck-us.net> <20150223160109.GB27057@lunn.ch> <54EB6BF5.2020600@gmail.com> <20150223183537.GA23456@roeck-us.net> <54EDD172.4010606@nexvision.fr> <54EDDB72.1090706@roeck-us.net> <54F0A4DE.3020704@nexvision.fr> <54F17408.4080105@roeck-us.net> <54F475E8.8010408@nexvision.fr> <54F47876.2000104@roeck-us.net> <54F48152.4070205@nexvision.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	jerome.oufella@savoirfairelinux.com,
	Chris Healy <cphealy@gmail.com>
To: Andrey Volkov <andrey.volkov@nexvision.fr>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:57764 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754523AbbCBRRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:17:10 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YSTxt-004ByQ-UZ
	for netdev@vger.kernel.org; Mon, 02 Mar 2015 17:17:10 +0000
In-Reply-To: <54F48152.4070205@nexvision.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/02/2015 07:27 AM, Andrey Volkov wrote:
> On 02/03/2015 15:49, Guenter Roeck wrote:
>> On 03/02/2015 06:38 AM, Andrey Volkov wrote:
>>>
>>> On 28/02/2015 08:53, Guenter Roeck wrote:
>>>> On 02/27/2015 09:09 AM, Andrey Volkov wrote:
>>>>> Gunter,
>>>>>
>>>>> Sorry with response delay, I very was busy yesterday
>>>>>
>>>>> Le 25/02/2015 15:25, Guenter Roeck a =E9crit :
>>>>>> Andrey,
>>>>>
>>>>> ------- snip -------
>>>>>
>>>>>>>>
>>>>>>> I simply modify port's fid to the new one in the leave routine =
and set to common bridge FID in enter
>>>>>>> (I'm using Marvell's chips). So the port's database will cleane=
d up automatically for the leave and will
>>>>>>> contain something useful at the enter time. Also I've look thro=
ugh yours patches and I haven't
>>>>>>
>>>>>> Does removing a port from a fid clean up the entries associated =
with it
>>>>>> in the database ?
>>>>>
>>>>> I've checked what happened when port changed its FID: switch logi=
c block traffic to it
>>>>> immediately, as far as I can see, meanwhile record still exists i=
n the bridge database,
>>>>> it was checked on 88e6185, 88e6097 and 88e6352 chips. And yet ano=
ther 5c: changing of group membership is
>>>>> not atomic operation in the Marvell's chips known for me, so the =
port must be in the disabled state when it
>>>>> will happened.
>>>>>
>>>> Hmm - interesting. I assume you mean updating port registers 5 and=
 6 ?
>>> Yes sure, it's reason why we must disable the port before changing =
the FID.
>>>
>> Yes, I think we'll need to do that once we use the bits in register =
5.
>>
>>>>
>>>> Different question: For 6185, did you write a new driver or extend=
 an existing one ?
>>>> I found that it is quite similar to 6131, and that adding support =
for it to the 6131
>>>> driver should be straightforward.
>>> Yes again :), and 88E6097 have same core as 6123_61_65. Difference =
in both cases only in the number
>>> of supported ports, and it was main reason why hardcoded port's num=
ber was unacceptable for me, difference is
>>> large enough: for ex. 88e6123 have only 3 ports, but 88E6097 - 11.
>>>
>>
>> I have a patch set to change the number of ports to a variable in th=
e 6131 driver.
>> Want me to submit it now ? Though I guess you must have pretty much =
the same,
>> so we can also use your approach. Let me know.
>
> I think that better to start from my patches: they are more generic a=
nd have support of sysfs
> (should be useful for "MII over ethernet"). Also IMO it will be bette=
r if we continue exchange/prereview

Sure, no problem. Only concern I have is that your patches don't seem t=
o be available
in public, or maybe I missed the reference to it.

> our patches in more narrow mail list, since I do not want to pollute =
netdev by useless discussions about drafts.
> Objections/suggestions?
>
Sure, no problem, though personally I have no issues with the discussio=
ns
or with submitting draft patches, and I did not have the impression tha=
t
they are useless.

My patches are all in my repository at kernel.org; it is fine with me t=
o keep
them (only) there if submitting drafts to netdev is considered pollutio=
n.

Thanks,
Guenter
