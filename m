From: =?windows-1252?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc@tvcablenet.be>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 17:42:04 +0200
Message-ID: <4887514C.6080903@tvcablenet.be>
References: <bug-11144-10286@http.bugzilla.kernel.org/>	<20080722034850.dbbc5566.akpm@linux-foundation.org>	<4886E49D.6010700@tvcablenet.be> <20080723010522.389a948f.akpm@linux-foundation.org> <4886F727.6010301@tvcablenet.be> <48870425.50908@trash.net> <48871632.3010205@tvcablenet.be> <4887169B.6090102@trash.net> <488725D5.8030900@tvcablenet.be> <488727B3.7040007@trash.net> <48872968.9000103@trash.net> <488746DF.1050501@tvcablenet.be> <48874BD8.60600@trash.net> <48874C12.10606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ananke.telenet-ops.be ([195.130.137.78]:45454 "EHLO
	ananke.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbYGWPmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 11:42:07 -0400
In-Reply-To: <48874C12.10606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Patrick McHardy wrote:
>> Fran=E7ois Valenduc wrote:
>>> I did the bisection again, this time on the whole tree and the firs=
t=20
>>> bad commit is again the one I mentioned previously:
>>>
>>> 175f9c1bba9b825d22b142d183c9e175488b260c is first bad commit
>>> commit 175f9c1bba9b825d22b142d183c9e175488b260c
>>> Author: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
>>> Date: Sun Jul 20 00:08:47 2008 -0700
>>>
>>> net_sched: Add size table for qdiscs
>>>
>>> Add size table functions for qdiscs and calculate packet size in
>>> qdisc_enqueue().
>>>
>>> Based on patch by Patrick McHardy
>>> http://marc.info/?l=3Dlinux-netdev&m=3D115201979221729&w=3D2
>>>
>>> This time, I didn't encounter kernels which didn't compile. So, I=20
>>> didn't use git-reset or git-bisect skip.
>>
>>
>> I think I know whats happening (Jussi CCed). That commit introduced
>> a qdisc_skb_cb, which conflicts with the mac80211 usage of skb->cb.
>> mac80211 seems to expect the CB to survive the qdisc layer, which
>> is wrong. One possibility to fix this (or just test my theory)
>> would be to make sure they don't clash by adding the struct
>> ieee80211_tx_info to qdisc_skb_cb->data. Something like this patch.
>>
>
> > +#include <net/sched_generic.h>
>
> That should be sch_generic.h.
>
I tested your last patch. Unfortunately, I get the following compile er=
ror:

In file included from net/mac80211/main.c:11:
include/net/mac80211.h: In function =91IEEE80211_SKB_CB=92:
include/net/mac80211.h:347: erreur: size of array =91type name=92 is ne=
gative


=46ran=E7ois
