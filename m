From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 08:58:54 -0700
Message-ID: <CA+mtBx990LcBrZVhfNk224cofpDWGeOD=F0Nbe0DWoEF=LvOUA@mail.gmail.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<54234225.5000503@mojatatu.com>
	<20140925102505.494acab1@redhat.com>
	<54240F34.1050707@mojatatu.com>
	<CA+mtBx8Nie9AiCG6iuY+EN7HiLAe-bxWpZxTpRhASmYabRUyFA@mail.gmail.com>
	<20140925165738.646d0783@redhat.com>
	<CA+mtBx9ZW0qYh+_BEEVTgZ79Xbq0bH1Agfss_7kdEus_syeMhA@mail.gmail.com>
	<20140925172329.7460f787@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37661 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753013AbaIYP6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 11:58:55 -0400
Received: by mail-ig0-f178.google.com with SMTP id r10so8653038igi.5
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 08:58:54 -0700 (PDT)
In-Reply-To: <20140925172329.7460f787@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 8:23 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Thu, 25 Sep 2014 08:05:38 -0700
> Tom Herbert <therbert@google.com> wrote:
>
>> On Thu, Sep 25, 2014 at 7:57 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > On Thu, 25 Sep 2014 07:40:33 -0700
>> > Tom Herbert <therbert@google.com> wrote:
>> >
>> >> A few test results in patch 0 are good. I like to have results for
>> >> with and without patch. These should two things: 1) Any regressions
>> >> caused by the patch 2) Performance gains (in that order of importance
>> >> :-) ). There doesn't need to be a lot here, just something reasonably
>> >> representative, simple, and should be easily reproducible. My
>> >> expectation in bulk dequeue is that we should see no obvious
>> >> regression and hopefully an improvement in CPU utilization-- are you
>> >> able to verify this?
>> >
>> > We are saving 3% CPU, as I described in my post with subject:
>> > "qdisc/UDP_STREAM: measuring effect of qdisc bulk dequeue":
>> >  http://thread.gmane.org/gmane.linux.network/331152/focus=331154
>> >
>> > Using UDP_STREAM on 1Gbit/s driver igb, I can show that the
>> > _raw_spin_lock calls are reduced with approx 3%, when enabling
>> > bulking of just 2 packets.
>> >
>>
>> That's great. In commit log, would be good to have results with
>> TCP_STREAM also and please report aggregate CPU utilization changes
>> (like from mpstat).
>
> The TCP_STREAM is not a good test for this, because unless disabling
> both TSO and GSO the packets will not hit the code path (that this
> patch changes).  When we later add support for TSO and GSO bulking,
> then it will make sense to include TCP_STREAM testing, not before.
>
Disabling TSO and GSO is fine. I'm interested to see interactions with TCP.

> I will redo the tests, once I get home to my testlab, as the remote lab
> I'm using now is annoyingly slow rebooting machines, as we not longer
> have a runtime option for enable/disable (I'm currently in Switzerland).
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Sr. Network Kernel Developer at Red Hat
>   Author of http://www.iptv-analyzer.org
>   LinkedIn: http://www.linkedin.com/in/brouer
