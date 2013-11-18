From: =?UTF-8?B?SG9sZ2VyIEhvZmZzdMOkdHRl?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Mon, 18 Nov 2013 17:26:16 +0100
Message-ID: <528A3FA8.8020202@googlemail.com>
References: <8761s0cqhh.fsf@natisbad.org> <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org> <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com> <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com> <8738n0ngq3.fsf@natisbad.org> <pan.2013.11.13.21.59.50.578858@googlemail.com> <1384386040.28458.143.camel@edumazet-glaptop2.roam.corp.google.com> <pan.2013.11.13.23.52.41.470832@googlemail.com> <20131117231545.GA32350@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.modasys.de ([217.69.76.98]:55430 "EHLO services.iobjects.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751476Ab3KRQdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Nov 2013 11:33:54 -0500
In-Reply-To: <20131117231545.GA32350@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/18/13 00:15, Francois Romieu wrote:
> Holger Hoffstaette <holger.hoffstaette@googlemail.com> :
> [...]
>> Since I saw this with r8169->r8169 and e1000e->r8169 it's probably
>> everyone's favourite r8169 :)
>> Unfortunately I can't be more help but if you can suggest/whip up a fix
>> I'd be happy to help test.
> 
> The r8169 driver does not rely on a timer for Tx completion.

Thankx, that's good to hear.

> The patch below should not hurt.

It does not seem to hurt, but neither can I notice much of a change.
However that's probably because of some other side effects, see below.

Do I understand the diff correctly that it makes the driver perform
outstanding transmissions before budgeting reads? Just curious.

> Can you describe your system a bit more specifically ?

Server has r8169, client is either r8169 (Windows/linux) or Thinkpad
with e1000e. Clients use NFS & Samba. Since Eric's TSQ patch the erratic
3.12.0-vanilla behaviour has "stabilized" in the sense that latency &
throughout became relatively smooth and more or less as expected, both
for large copies and many small files.

However since then I found that increasing the tcp_limit_output_bytes to
262144 (twice the default of 128k) makes things really fly. Copying
large files (>1GB) over NFS from the e1000e now quickly reaches the full
1Gb line throughput. This was really surprising.

Apart from the laptop being relatively old and being difficult to
benchmark due to typical power state scaling, I suspect the e1000e
running with dynamic interrupt moderation is not completely innocent
either. I used to turn this off some years back and had great success,
but that was on Windows.

Long story short there's just too much up- and downscaling, buffering
and queueing involved in all parts to point to any single culprit, but
increasing the byte limit *has* helped everywhere and had no noticeable
impact on internet traffic. I understand the motivation for small queues
from a bufferbloat-fighting point of view (using fq_codel did wonders
for a friend without external router!), but apparently for LAN traffic
this doesn't seem to work in all cases.

Not sure if any of this is helpful. :)

cheers
Holger
