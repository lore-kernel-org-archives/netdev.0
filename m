From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 6/9] actions:  add skbmod action
Date: Sun, 9 Oct 2016 19:08:17 -0700
Message-ID: <20161009190817.16ea41cb@xeon-e3>
References: <1475354917-7912-1-git-send-email-jhs@emojatatu.com>
        <1475354917-7912-7-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:32792 "EHLO
        mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbcJJCIC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 22:08:02 -0400
Received: by mail-pa0-f52.google.com with SMTP id vu5so8102209pab.0
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 19:08:02 -0700 (PDT)
In-Reply-To: <1475354917-7912-7-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  1 Oct 2016 16:48:34 -0400
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> This action is intended to be an upgrade from a usability perspective
> from pedit (as well as operational debugability).
> Compare this:
> 
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action pedit munge offset -14 u8 set 0x02 \
>     munge offset -13 u8 set 0x15 \
>     munge offset -12 u8 set 0x15 \
>     munge offset -11 u8 set 0x15 \
>     munge offset -10 u16 set 0x1515 \
>     pipe
> 
> to:
> 
> sudo tc filter add dev $ETH parent 1: protocol ip prio 10 \
> u32 match ip protocol 1 0xff flowid 1:2 \
> action skbmod dmac 02:15:15:15:15:15
> 
> Or worse, try to debug a policy with destination mac, source mac and
> etherype. Then make that a hundred rules and you'll get my point.
> 
> The most important ethernet use case at the moment is when redirecting or
> mirroring packets to a remote machine. The dst mac address needs a re-write
> so that it doesnt get dropped or confuse an interconnecting (learning) switch
> or dropped by a target machine (which looks at the dst mac).
> 
> In the future common use cases on pedit can be migrated to this action
> (as an example different fields in ip v4/6, transports like tcp/udp/sctp
> etc). For this first cut, this allows modifying basic ethernet header.
> 
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Lots of checkpatch errors on this. Please fix and resubmit series.
For example:

ERROR: spaces required around that '+=' (ctx:WxV)
#442: FILE: tc/m_skbmod.c:79:
+			ok +=1;


ERROR: code indent should use tabs where possible
#567: FILE: tc/m_skbmod.c:204:
+        SPRINT_BUF(b1);$

WARNING: please, no spaces at the start of a line
#567: FILE: tc/m_skbmod.c:204:
+        SPRINT_BUF(b1);$

ERROR: code indent should use tabs where possible
#568: FILE: tc/m_skbmod.c:205:
+        SPRINT_BUF(b2);$

WARNING: please, no spaces at the start of a line
#568: FILE: tc/m_skbmod.c:205:
+        SPRINT_BUF(b2);$

WARNING: braces {} are not necessary for single statement blocks
#610: FILE: tc/m_skbmod.c:247:
+	if (p->flags & SKBMOD_F_SWAPMAC) {
+		fprintf(f, "swap mac ");
+	}


ERROR: trailing whitespace
#816: FILE: man/man8/tc-skbmod.8:28:
+.IR CONTROL " := {"                                                             $
