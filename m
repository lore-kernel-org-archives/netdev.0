From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH net-next 0/2] netfilter: IPv4/v6 IPcomp match support
Date: Fri, 20 Dec 2013 17:21:05 +0800
Message-ID: <52B40C01.7070406@windriver.com>
References: <1386937082-30412-1-git-send-email-fan.du@windriver.com> <20131217130555.GA8874@localhost> <52B26841.40800@windriver.com> <20131220090419.GA5661@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39088 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950Ab3LTJVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 04:21:15 -0500
In-Reply-To: <20131220090419.GA5661@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8820=E6=97=A5 17:04, Pablo Neira Ayuso wrote:
> On Thu, Dec 19, 2013 at 11:30:09AM +0800, Fan Du wrote:
>>
>>
>> On 2013=E5=B9=B412=E6=9C=8817=E6=97=A5 21:05, Pablo Neira Ayuso wrot=
e:
>>> On Fri, Dec 13, 2013 at 08:18:00PM +0800, Fan Du wrote:
>>>> Hi,
>>>>
>>>> This patchset adds IPv4/v6 IPComp 'match' plugin to enables user s=
etting
>>>> ACTONs for IPcomp flows sepecified with SPI value.
>>>>
>>>> Corresponding iptables patchset will be sent here after soon.
>>>>
>>>> Fan Du (2):
>>>>    netfilter: add IPv4 IPComp extension match support
>>>>    netfilter: add IPv6 IPComp extension match support
>>>
>>> This looks good, but I have to ask you to merge those two modules i=
nto
>>> one single xt_ipcomp, they are fairly small and we can save the
>>> overhead of having two different modules. Moreover, at quick glance=
 I
>>> don't see any dependency with IPv4/IPv6 exported symbols that may
>>> cause ifdef pollution.
>>>
>>> Please, see net/netfilter/xt_tcpudp.c as reference to rework this.
>>> Thanks.
>>>
>>
>> I noticed netfilter ipv4/v6 AH support also has split implementation=
,
>> so far, by my understanding, it's fairly enough to consolidate those
>> two implementations into one as well, as IPv4/6 AH head format are
>> identical.
>>
>> If you don't mind or it won't break anything internal for netfilter,
>> I plan to combine them into one piece.
>
> We can merge those two, but you'll have to handle dependencies with
> IPv6 core via ifdefs and Kconfig to avoid problems.
>
> AH is not the last header, so we still have to use ipv6_find_hdr() to
> find the good header instead of par->thoff. Note that the ip6_tables
> sets par->thoff to the last IPv6 extension header.

I'm quite new to the internal of netfiler, especially about this part.
I will take a look at the code later.

> This rises some concerns regarding your ipcomp, I think that if you
> use this with ah and esp, the ordering of the headers is
> ah+ipcomp+esp, right?

This depends on the user land configuration of encapsulation order.
It can be one of the three types only(ah, esp, ipcomp), the most common=
ly
used is ah(outer)+esp(inner).

I barely see ipcomp used in production, but I remember RFC says ipcomp
should be done first before esp, because after encryption in esp, the d=
ata
is polluted, i.e., not suitable for compressed anymore(I'm not sure the
details theory behind this statement.)

Anyway, no matter how ah,esp,ipcomp are ordered, I think it only makes
sense for the outer header when using any one of those three filters, a=
nd
that's what I can imagine how it's been used.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
