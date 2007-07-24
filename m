From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 00/10] Implement batching skb API
Date: Tue, 24 Jul 2007 15:28:20 -0400
Message-ID: <1185305300.26013.152.camel@localhost>
References: <OF782207DD.01F7022B-ON65257322.000F7C16-65257322.0014942E@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, rdreier@cisco.com,
	rick.jones2@hp.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.228]:6416 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754465AbXGXT2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 15:28:25 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1913654wxd
        for <netdev@vger.kernel.org>; Tue, 24 Jul 2007 12:28:25 -0700 (PDT)
In-Reply-To: <OF782207DD.01F7022B-ON65257322.000F7C16-65257322.0014942E@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

KK,

On Tue, 2007-24-07 at 09:14 +0530, Krishna Kumar2 wrote:

> 
> J Hadi Salim <j.hadi123@gmail.com> wrote on 07/23/2007 06:02:01 PM:


> Actually you have not sent netperf results with prep and without prep.

My results were based on pktgen (which i explained as testing the
driver). I think depending on netperf without further analysis is
simplistic. It was like me doing forwarding tests on these patches.

> > So _which_ non-LLTX driver doesnt do that? ;->
> 
> I have no idea since I haven't looked at all drivers. Can you tell which
> all non-LLTX drivers does that ? I stated this as the sole criterea.

The few i have peeked at all do it. I also think the e1000 should be
converted to be non-LLTX. The rest of netdev is screaming to kill LLTX. 

> > tun driver doesnt use it either - but i doubt that makes it "bloat"
> 
> Adding extra code that is currently not usable (esp from a submission
> point) is bloat.

So far i have converted 3 drivers, 1 of them doesnt use it. Two more
driver conversions are on the way, they will both use it. How is this
bloat again? 
A few emails back you said if only IPOIB can use batching then thats
good enough justification. 

> > You waltz in, have the luxury of looking at my code, presentations, many
> > discussions with me etc ...
> 
> "luxury" ? 
> I had implemented the entire thing even before knowing that you
> are working on something similar! and I had sent the first proposal to
> netdev,

I saw your patch at the end of may (or at least 2 weeks after you said
it existed). That patch has very little resemblance to what you just
posted conceptwise or codewise. I could post it if you would give me
permission.

> *after* which you told that you have your own code and presentations (which
> I had never seen earlier - I joined netdev a few months back, earlier I was
> working on RDMA, Infiniband as you know).

I am gonna assume you didnt know of my work - which i have been making
public for about 3 years. Infact i talked about this topic when i
visited your office in 2006 on a day you were not present, so it is
plausible you didnt hear of it.

>  And it didn't give me any great
> ideas either, remember I had posted results for E1000 at the time of
> sending the proposals. 

In mid-June you sent me a series of patches which included anything from
changing variable names to combining qdisc_restart and about everything
i referred to as being "cosmetic differences" in your posted patches. I
took two of those and incorporated them in. One was an "XXX" in my code
already to allocate the dev->blist 
(Commit: bb4464c5f67e2a69ffb233fcf07aede8657e4f63). 
The other one was a mechanical removal of the blist being passed
(Commit: 0e9959e5ee6f6d46747c97ca8edc91b3eefa0757). 
Some of the others i asked you to defer. For example, the reason i gave
you for not merging any qdisc_restart_combine changes is because i was
waiting for Dave to swallow the qdisc_restart changes i made; otherwise
maintainance becomes extremely painful for me. 
Sridhar actually provided a lot more valuable comments and fixes but has
not planted a flag on behalf of the queen of spain like you did. 

> However I do give credit in my proposal to you for what
> ideas that your provided (without actual code), and the same I did for other
> people who did the same, like Dave, Sridhar. BTW, you too had discussions with me,
> and I sent some patches to improve your code too, 

I incorporated two of your patches and asked for deferal of others.
These patches have now shown up in what you claim as "the difference". I
just call them "cosmetic difference" not to downplay the importance of
having an ethtool interface but because they do not make batching
perform any better. The real differences are those two items. I am
suprised you havent cannibalized those changes as well. I thought you
renamed them to something else; according to your posting:
"This patch will work with drivers updated by Jamal, Matt & Michael Chan
with minor modifications - rename xmit_win to xmit_slots & rename batch
handler". Or maybe thats a "future plan" you have in mind?

> so it looks like a two
> way street to me (and that is how open source works and should).

Open source is a lot more transparent than that.

You posted a question, which was part of your research. I responded and
told you i have patches; you asked me for them and i promptly ported
them from pre-2.6.18 to the latest kernel at the time. 

The nature of this batching work is one of performance. So numbers are
important. If you had some strong disagreements on something in the
architecture, then it would be of great value to explain it in a
technical detail - and more importantly to provide some numbers to say
why it is a bad idea. You get numbers by running some tests. 
You did none of the above. Your effort has been to produce "your patch"
for whatever reasons. This would not have been problematic to me if it
actually was based within reasons of optimization because the end goal
would have been achieved.

I have deleted the rest of the email because it goes back and forth on
the same points. 

I am gonna continue work on the current tree i have. I will put more
time when i get back next week (and hopefully no travel right after).
I will upgrade to Daves tree later when i get the two new drivers in. I
am probably gonna hold on until the new NAPI stuff settles in first. You
are welcome to  submit the ipoib changes in. You are also welcome to
co-author with me but you will have to work for it this time.

cheers,
jamal

