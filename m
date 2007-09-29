From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.23-rc8-mm2 - tcp_fastretrans_alert() WARNING
Date: Sat, 29 Sep 2007 23:49:30 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0709292333480.8339@kivilampi-30.cs.helsinki.fi>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
 <46FD20F0.3050909@fr.ibm.com> <Pine.LNX.4.64.0709282143020.6013@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0709291532200.6776@kivilampi-30.cs.helsinki.fi>
 <46FE6751.3050205@free.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1047178236-1191098970=:8339"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:36085 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751496AbXI2Ute (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 16:49:34 -0400
In-Reply-To: <46FE6751.3050205@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1047178236-1191098970=:8339
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sat, 29 Sep 2007, Cedric Le Goater wrote:

> Ilpo Järvinen wrote:
> > On Fri, 28 Sep 2007, Ilpo Järvinen wrote:
> >> On Fri, 28 Sep 2007, Cedric Le Goater wrote:
> >>
> >>> I just found that warning in my logs. It seems that it's been 
> >>> happening since rc7-mm1 at least. 
> >>>
> >>> WARNING: at /home/legoater/linux/2.6.23-rc8-mm2/net/ipv4/tcp_input.c:2314 tcp_fastretrans_alert()
> >>>
> >>> Call Trace:
> >>>  <IRQ>  [<ffffffff8040fdc3>] tcp_ack+0xcd6/0x1894
> >>> ...snip...
> >> ...Thanks for the report, I'll have look what could still break 
> >> fackets_out...
> > 
> > I think this one is now clear to me, tcp_fragment/collapse adjusts 
> > fackets_out (incorrectly) also for reno flow when there were some dupACKs 
> > that made sacked_out != 0. Could you please try if patch below proves all 
> > them to be of non-SACK origin... In case that's true, it's rather 
> > harmless, I'll send a fix on Monday or so (this would anyway be needed)... 
> > If you find out that them occur with SACK enabled flow, that would be
> > more interesting and requires more digging...
> 
> I'm trying now to reproduce this WARNING. 
> 
> It seems that the n/w behaves differently during the week ends. Probably
> taking a break. 

Thanks.

Of course there are other means too to determine if TCP flows do negotiate 
SACK enabled or not. Depending on your test case (which is fully unknown 
to me) they may or may not be usable... At least the value of tcp_sack 
sysctl on both systems or tcpdump catching SYN packets should give that 
detail. ...If you know to which hosts TCP could be connected (and active) 
to, while the WARNING triggers, it's really easy to test what is being 
negotiated as it's unlikely to change at short notice and any TCP flow to 
that host will get us the same information though the WARNING would not be 
triggered with it at this time. Obviously if at least one of the remotes 
is not known or the set ends up being mixture of reno and SACK flows, then 
we'll just have to wait and see which fish we get...


-- 
 i.
---696243703-1047178236-1191098970=:8339--
