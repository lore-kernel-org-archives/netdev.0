From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during softnet
 overflow
Date: Tue, 23 Apr 2013 21:44:37 -0400
Message-ID: <51773905.9030005@mojatatu.com>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>   <1366749094-5982-1-git-send-email-willemb@google.com>   <20130423142333.15479dfa@nehalam.linuxnetplumber.net>   <1366753063.8964.14.camel@edumazet-glaptop>   <20130423145222.5b696d0c@nehalam.linuxnetplumber.net>  <1366762196.8964.46.camel@edumazet-glaptop> <517734A2.9060609@mojatatu.com> <1366767151.8964.56.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010306020506090507080302"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Willem de Bruijn <willemb@google.com>,
	netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:41784 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754902Ab3DXBok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 21:44:40 -0400
Received: by mail-ob0-f173.google.com with SMTP id xn12so1045213obc.4
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 18:44:40 -0700 (PDT)
In-Reply-To: <1366767151.8964.56.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010306020506090507080302
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 13-04-23 09:32 PM, Eric Dumazet wrote:
> On Tue, 2013-04-23 at 21:25 -0400, Jamal Hadi Salim wrote:


> Not sure what you mean. The qdisc stuff would replace the 'cpu backlog',

Aha ;->
So you would have many little backlogs one per ring per cpu, correct?


> not be added to it. Think of having possibility to control backlog using
> standard qdiscs, like fq_codel ;)

Excellent. So this is not as a big surgery as it sounds then.
the backloglets just need to be exposed as netdevs.

> Yes, but the per cpu backlog is shared for all devices. We probably want
> different qdisc for gre tunnel, eth0, ...

Makes sense.

BTW, looking at __skb_get_rxhash(), if i had a driver that sets either
skb->rxhash (picks it off the dma descriptor), could i not use that 
instead of computing the hash? something like attached patch.

cheers,
jamal

--------------010306020506090507080302
Content-Type: text/plain; charset=UTF-8;
 name="p1"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="p1"

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL2Zsb3dfZGlzc2VjdG9yLmMgYi9uZXQvY29yZS9mbG93
X2Rpc3NlY3Rvci5jCmluZGV4IGUxODdiZjAuLmE2YWJlZTAgMTAwNjQ0Ci0tLSBhL25ldC9j
b3JlL2Zsb3dfZGlzc2VjdG9yLmMKKysrIGIvbmV0L2NvcmUvZmxvd19kaXNzZWN0b3IuYwpA
QCAtMTU5LDggKzE1OSw5IEBAIHZvaWQgX19za2JfZ2V0X3J4aGFzaChzdHJ1Y3Qgc2tfYnVm
ZiAqc2tiKQogCXN0cnVjdCBmbG93X2tleXMga2V5czsKIAl1MzIgaGFzaDsKIAotCWlmICgh
c2tiX2Zsb3dfZGlzc2VjdChza2IsICZrZXlzKSkKKwlpZiAoc2tiLT5yeGhhc2ggfHwgIXNr
Yl9mbG93X2Rpc3NlY3Qoc2tiLCAma2V5cykpIHsKIAkJcmV0dXJuOworCX0KIAogCWlmIChr
ZXlzLnBvcnRzKQogCQlza2ItPmw0X3J4aGFzaCA9IDE7Cg==
--------------010306020506090507080302--
