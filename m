From: Tobias Klausmann <klausman@schwarzvogel.de>
Subject: Re: Possible race condition in conntracking
Date: Tue, 27 Jan 2009 14:28:10 +0100
Message-ID: <20090127132810.GA21498@eric.schwarzvogel.de>
References: <20090127075744.GA19875@eric.schwarzvogel.de> <497ED1E1.40304@trash.net> <20090127130604.GA19883@eric.schwarzvogel.de> <497F08C4.90705@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eric.schwarzvogel.de ([194.97.4.250]:39064 "EHLO
	eric.schwarzvogel.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbZA0N2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 08:28:12 -0500
Content-Disposition: inline
In-Reply-To: <497F08C4.90705@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi! 

On Tue, 27 Jan 2009, Patrick McHardy wrote:
> Tobias Klausmann wrote:
>> So, as far as rule-matching is concerned, the two packets are
>> handled identically. Whatever happens after this:
>> Jan 27 11:00:39 fw2 kernel: TRACE: nat:POSTROUTING:policy:3 IN=
>> OUT=eth2.188 SRC=194.97.7.116 DST=194.97.3.83 LEN=66 TOS=0x00
>> PREC=0x00 TTL=63 ID=46964 DF PROTO=UDP SPT=53452 DPT=53 LEN=46 is making 
>> this very packet go away. The policy of nat/PR is
>> ACCEPT.
>
> This just means it passed through the last table/chain. The
> only one following is conntrack confirmation.
>
> Damn it :) I just noticed, we do indeed drop packets from
> duplicate new connections in conntrack confirmation.

So the question remains what to do instead and how to do it. That
probably is deep Netfilter mojo, so I could only speculate wildly.

> You should see the insert_failed conntrack counter show this
> (/proc/net/stat/nf_conntrack).

We do, as I said in my first mail. Near as I can tell,
nf_conntrack_confirm() is the only function that ever increases
that counter, so it's definitely dropped there. As to how one
could handle it differently, I have to defer to people with more
Netfilter expertise. No point in "fixing" this by breaking other
stuff.

Regards,
Tobias

-- 
printk("Cool stuff's happening!\n")
        linux-2.4.3/fs/jffs/intrep.c
