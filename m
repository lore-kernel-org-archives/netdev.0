From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [regression] nf_iterate(), BUG: unable to handle kernel NULL
 pointer dereference
Date: Thu, 24 Jul 2008 20:00:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807241944450.1907@bizon.gios.gov.pl>
References: <20080724060448.GA10203@elte.hu> <E1KLwlD-0001Ub-00@gondolin.me.apana.org.au>
 <20080724.022259.113079007.davem@davemloft.net> <20080724093411.GA12001@elte.hu>
 <20080724115625.GA23994@elte.hu> <20080724115957.GA25701@elte.hu>
 <20080724142353.GA400@elte.hu> <48889E57.2000007@trash.net>
 <20080724153248.GA25056@elte.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-385197319-1216922426=:1907"
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	herbert@gondor.apana.org.au, w@1wt.eu, davidn@davidnewall.com,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	stefanr@s5r6.in-berlin.de, rjw@sisk.pl, ilpo.jarvinen@helsinki.fi,
	Dave Jones <davej@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:56401 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbYGXSJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 14:09:40 -0400
In-Reply-To: <20080724153248.GA25056@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-385197319-1216922426=:1907
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 24 Jul 2008, Ingo Molnar wrote:

>
> * Patrick McHardy <kaber@trash.net> wrote:
>
>> Ingo Molnar wrote:
>>> Then i tried both suggested fix patches Patrick sent me (a suggested
>>> revert and an netfilter/RCU use-after-free fix), but none of them
>>> solved the crash.
>>
>> Just to make sure - the "netfilter/RCU use-after-free fix" was the
>> patch from Pekka?
>
> yes. You can see it in tip/out-of-tree:
>
>   http://people.redhat.com/mingo/tip.git/README
>
>>> Thus i finally arrived to:
>>>
>>>  # good: [ae6134bd] hdlcdrv: Fix CRC calculation.
>>>  # bad:  [5547cd0d] netfilter: nf_conntrack_sctp: fix sparse warnings
>>>  # bad:  [280763c6] netfilter: xt_time: fix time's time_mt()'s use of
>>>  # good: [07a7c10b] netlink: add NLA_PUT_BE64 macro
>>>  # bad:  [58401573] netfilter: accounting rework: ct_extend + 64bit co
>>>
>>> | 584015727a3b88b46602b20077b46cd04f8b4ab3 is first bad commit
>>> | commit 584015727a3b88b46602b20077b46cd04f8b4ab3
>>> | Author: Krzysztof Piotr Oledzki <ole@ans.pl>
>>> | AuthorDate: Mon Jul 21 10:01:34 2008 -0700
>>> | Commit:     David S. Miller <davem@davemloft.net>
>>> | CommitDate: Mon Jul 21 10:10:58 2008 -0700
>>> |
>>> |    netfilter: accounting rework: ct_extend + 64bit counters (v4)
>>> [...]
>>> |     Signed-off-by: Krzysztof Piotr Oledzki <ole@ans.pl>
>>> |     Signed-off-by: Patrick McHardy <kaber@trash.net>
>>> |     Signed-off-by: David S. Miller <davem@davemloft.net>
>>>
>>> Which i double-checked by reverting that commit from -git as well and
>>> that solved the crash. Find the tested reverter patch below.
>>
>> Thats odd. I don't think anything is wrong with that patch itself, its
>> more likely that its triggering a bug in ct_extend. You config has a
>> few helper enabled (FTP, H.323, TFTP) and the crash is when trying to
>> call the helper functions. Did you actually have traffic of one of
>> these protocols?
>
> no, that's not likely - it's a default distro bootup.

The commit makes ct_extend area to be used *very* frequently. Could you=20
try to boot your kernel with nf_conntrack.acct=3D0 to disable accounting?
Does it help?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-385197319-1216922426=:1907--
