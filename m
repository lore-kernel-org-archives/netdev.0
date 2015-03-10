From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: use sock_efree instead of own destructor
Date: Tue, 10 Mar 2015 14:36:21 +0100
Message-ID: <54FEF355.305@hartkopp.net>
References: <1425959300-27132-1-git-send-email-fw@strlen.de>	 <54FE8BB0.9050508@hartkopp.net> <1425990143.8261.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	mkl@pengutronix.de,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:46587 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752325AbbCJNgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 09:36:31 -0400
In-Reply-To: <1425990143.8261.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yes - in connection with sock_rfree() for the read buffer destructur and
sock_wfree() for the write buffer it can make sense to name a function
sock_efree() as an unassigned destructor - which does not fiddle with rmem nor
wmen.

But both sock_efree() and sock_edemux() lack some comment - especially when it
makes sense to use them from non-INET contexts which Florian suggested.

Maybe Alexander can send a patch which adds a comment, as I don't know if I
would find the best words for it.

Regards,
Oliver

On 03/10/2015 01:22 PM, Eric Dumazet wrote:
> On Tue, 2015-03-10 at 07:14 +0100, Oliver Hartkopp wrote:
> 
>> the other callers use it in the same way so it's a good simplification.
>> Btw. the name of sock_efree() is a bit misleading - nothing is free'd here.
>>
>> Won't it be better to rename sock_efree(skb) with sock_put_skb(skb) or 
>> something like that? sock_efree() has no comment why it's named like this.
> 
> I would prefer name stays as is. It eases searches in changelogs to not
> change function names unless really needed, for backports and code
> maintenance.
> 
> 
> # git log | grep sock_efree
>     net: merge cases where sock_efree and sock_edemux are the same function
>     Since sock_efree and sock_demux are essentially the same code for non-TCP
>     In addition I have added a destructor named sock_efree which is meant to
> 
> sock_efree was added in commit 62bccb8cdb69051b95a55ab0c489e3cab261c8ef
> 
> I guess Alexander chose the name close to sock_edemux() and sock_rfree() ones.
> 
> This makes sense to me at least.
> 
