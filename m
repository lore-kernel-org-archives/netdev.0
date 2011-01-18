From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: inbound connection problems when "netlink: test for all flags
	of the NLM_F_DUMP composite" commit applied
Date: Tue, 18 Jan 2011 09:38:11 +0000
Message-ID: <20110118093811.GA7520@ff.dom.local>
References: <4D336050.9030602@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arthur Marsh <arthur.marsh@internode.on.net>,
	Jan Engelhardt <jengelh@medozas.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64554 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab1ARJiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jan 2011 04:38:20 -0500
Received: by bwz15 with SMTP id 15so3170957bwz.19
        for <netdev@vger.kernel.org>; Tue, 18 Jan 2011 01:38:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D336050.9030602@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2011-01-16 22:17, Pablo Neira Ayuso wrote:
> On 16/01/11 13:25, Arthur Marsh wrote:
>> Jan Engelhardt wrote, on 16/01/11 21:20:
>>>
>>> Le dimanche 16 janvier 2011 =C3  19:24 +1030, Arthur Marsh a =C3=A9=
crit :
>>>>
>>>>> With kernels up to and including 2.6.37-git7, inbound telnetd-ssl
>>>>> connections worked fine. With kernel 2.6.37-git9 and later inboun=
d
>>>>> telnetd-ssl connections failed, and on machine shut-down, there
>>>>> were warning messages about daemons not return status.
>>>
>>> Which daemons are these? For reference, what distro do you happen
>>> to use?
>>
>> avahi-daemon (which gave multiple warning messages, hence I thought =
it
>> may have been multiple packages)
>>
>> I'm running Debian unstable with kernel.org kernels.
>>
>>>
>>>>> commit 0ab03c2b1478f2438d2c80204f7fef65b1bca9cf
>>>>>      netlink: test for all flags of the NLM_F_DUMP composite
>>>
>>> Each of the hunks in this commit is independent of another.
>>> Would you mind bisecting these too?
>>
>> Recompiling with the only the first patch (attached) resulted in a
>> repeat of the problem.
>>
>> I've removed one person from the cc: list as they did not want to
>> receive email about this even though they signed off the commit.
>=20
> Please, pass this patch to the avahi-daemon developers. They use an
> invalid netlink flag combination for dump operations.

Nothing in RFC suggests this is an invalid netlink flag combination,
and author's implementation had suported it:
ftp://ftp.rfc-editor.org/in-notes/rfc3549.txt

NLM_F_DUMP is called a convenience macro only, so might be interpreted
as a special kind of dump. BTW, isn't NLM_F_ATOMIC flag with
NLM_F_DUMP treated as invalid now either?

Even if I'm wrong, this change added to stable will break many configs.
My proposal is to revert commit 0ab03c2b147 until proper fix is found.

Cc: Jamal Hadi Salim <hadi@cyberus.ca>

Jarek P.
