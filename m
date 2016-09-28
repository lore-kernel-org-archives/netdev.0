From: Edward Cree <ecree@solarflare.com>
Subject: Local variable ordering (was Re: [PATCH v5 0/7] Reduce cache miss for
 snmp_fold_field)
Date: Wed, 28 Sep 2016 16:58:22 +0100
Message-ID: <5734f230-eafa-45a1-9635-98721f872b38@solarflare.com>
References: <1475043748-18161-1-git-send-email-hejianet@gmail.com>
 <20160928.050817.110671274247345232.davem@davemloft.net>
 <c44daa11-dc57-84fa-35cc-40ee0fe293f3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-sctp@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kuznet@ms2.inr.ac.ru>,
        <jmorris@namei.org>, <yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
        <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
        <steffen.klassert@secunet.com>, <herbert@gondor.apana.org.au>,
        <marcelo.leitner@gmail.com>
To: hejianet <hejianet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:29905 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932892AbcI1P6p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 11:58:45 -0400
In-Reply-To: <c44daa11-dc57-84fa-35cc-40ee0fe293f3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/09/16 14:45, hejianet wrote:
>
>
> On 9/28/16 5:08 PM, David Miller wrote:
>> From: Jia He <hejianet@gmail.com>
>> Date: Wed, 28 Sep 2016 14:22:21 +0800
>>
>>> v5:
>>> - order local variables from longest to shortest line
>> I still see many cases where this problem still exists.  Please
>> do not resubmit this patch series until you fix all of them.
>>
>> Patch #2:
>>
>> -static int snmp_seq_show(struct seq_file *seq, void *v)
>> +static int snmp_seq_show_ipstats(struct seq_file *seq, void *v)
>>   {
>>       int i;
>> +    u64 buff64[IPSTATS_MIB_MAX];
>>       struct net *net = seq->private;
>>
>> The order should be "net" then "buff64" then "i".
> Sorry for my bad eyesight and quick hand :(
> B.R.
> Jia
A few months back I wrote a script to help find these:
https://github.com/ecree-solarflare/xmastree
It can check a source file or a patch.
Posting in the hope that people will find it useful.

-Ed
