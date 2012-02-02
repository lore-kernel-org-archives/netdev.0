From: Jesse Gross <jesse@nicira.com>
Subject: Re: VLAN 1 - Native
Date: Thu, 2 Feb 2012 08:33:12 -0800
Message-ID: <CAEP_g=_c9W2YZU+RjQwVfdAW2nuCTxq2cTd0WxOU0-MmfmbOAg@mail.gmail.com>
References: <1328095366.10975.YahooMailNeo@web29004.mail.ird.yahoo.com>
 <1328095449.75127.YahooMailNeo@web29014.mail.ird.yahoo.com>
 <1328101484.2595.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CADDf=MQ8EYEtOO2e5NJLrW0DKDz5xCBEBwuY6rxNu4Cybq=kKQ@mail.gmail.com>
 <CADDf=MQ=0eadY-zT_YAgp17fo_xRUh0dg6nHCLpNXcMQnUdyCQ@mail.gmail.com>
 <1328108723.2595.33.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CADDf=MRDa6C47ToCnR3_cTkfJR8VL9UAScwzwGVUDn3O4nL6fA@mail.gmail.com>
 <1328114680.76107.YahooMailNeo@web29019.mail.ird.yahoo.com>
 <4F2991FD.8090407@ziu.info> <1328173741.73927.YahooMailNeo@web29018.mail.ird.yahoo.com>
 <1328173972.2279.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <4F2A7ECD.2050909@ziu.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Leonardo Uzcudun <uzcudunl@yahoo.it>,
	yao zhao <yao.development@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Soltys <soltys@ziu.info>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:42596 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab2BBQdc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 11:33:32 -0500
Received: by iacb35 with SMTP id b35so3342482iac.19
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2012 08:33:32 -0800 (PST)
In-Reply-To: <4F2A7ECD.2050909@ziu.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 2, 2012 at 4:17 AM, Michal Soltys <soltys@ziu.info> wrote:
> On 02.02.2012 10:12, Eric Dumazet wrote:
>>
>> Le jeudi 02 f=C3=A9vrier 2012 =C3=A0 09:09 +0000, Leonardo Uzcudun a=
 =C3=A9crit :
>>>
>>> Hello Michal:
>>>
>>> It is working on kernel 3.0.0-15 Ubuntu. I've just to modify the
>>> ebtables command as:
>>> ebtables -t broute -A BROUTING -i eth0 -p 802_1Q --vlan-id 101 -j D=
ROP
>>> (protocol is a must when you use --vlan-id)
>>>
>>>
>>> I'll test it on kernel 2.6.32-5 Debian
>>>
>>>
>>> Just last question,in the case i should implement this kind of
>>> configuration in a kernel 2.6.31, should i backport/patch anything?=
 is
>>> it a bad idea (running it on 2.6.31)?
>>
>>
>> This is going to be tough.
>>
>
> Btw, this (ebtables broute drop) method has been mentioned in bridge-=
nf faq
> for ages (through most/all 2.6 kernels at least) - and for the very p=
urpose
> of directing tagged/not tagged traffic to proper bridge interfaces.
> Shouldn't 2.6.31 be pretty safe in that regard ?
>
> Or did you mean backporting/patching part ?
>
>
>> The point of Jesse Gross (and others) work was exactly to permit bet=
ter
>> vlan/bridge integration/stacking.
>>
>
> Just to be sure - are those patches in any way changing / deprecating=
 /
> conflicting with ebtables approach ?

Nothing in ebtables changed.  The part that is different here is
whether the vlan device or the bridge takes priority for tagged
frames.  So on new kernels your ebtables command to reject packets
from the bridge back to the device isn't necessary because the device
will just take it in the first place but it shouldn't break things.

Based on your description, I suspect that this will work fine on your
old kernel.  Part of the problem that was fixed is that the result was
hardware dependent.
