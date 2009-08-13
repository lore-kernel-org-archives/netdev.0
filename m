From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [Iproute2]: failed replacing internal netem qdisc with pfifo
Date: Thu, 13 Aug 2009 23:32:19 +0200
Message-ID: <4A848663.4020304@gmail.com>
References: <2036847082.914731250159200857.JavaMail.root@zmail07.collab.prod.int.phx2.redhat.com> <20090813120330.GB7010@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	Patrick McHardy <kaber@trash.net>
To: Marcela Maslanova <mmaslano@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:42083 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756405AbZHMVc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 17:32:29 -0400
Received: by bwz22 with SMTP id 22so840727bwz.18
        for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 14:32:29 -0700 (PDT)
In-Reply-To: <20090813120330.GB7010@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote, On 08/13/2009 02:03 PM:

> On 13-08-2009 12:26, Marcela Maslanova wrote:
>> Hello,
>> I've received bug report about not being replaced netem with pfifo
>> anymore: https://bugzilla.redhat.com/show_bug.cgi?id=515522
>> This should be possible according to documentation [1].
>> Is this intentional change or is it a bug?
> 
> It's intentional:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=02201464119334690fe209849843881b8e9cfa9f
> 
>> It worked with kernel-2.6.27.5-117.fc10 and iproute-2.6.27. The problem
>> is still present with current iproute and kernel-2.6.29.6-217.2.3.fc11.
> 
> Yes, netem is classless since 2.6.29, so this documentation needs
> updating.


Hmm... I see this is passed to the user as "notabug". On the other hand,
since this functionality looks like useful (and used), I wonder if "we"
weren't too strict, and maybe it should be at least partially restored.
The clasfullness isn't actually a big problem if we skip reordering
(done by putting packets to the head of the queue) for such external
qdiscs. Alternatively we could modify netem's tfifo behavior (to pfifo)
with some option. Any suggestions?

Jarek P.
