From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Who's allowed to set a skb destructor?
Date: Fri, 6 Jul 2007 11:08:35 +0200
Message-ID: <20070706090835.GB2362@ff.dom.local>
References: <p733b032mec.fsf@bingen.suse.de> <20070705122849.GA4759@ff.dom.local> <20070705122847.GA13368@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Brice Goglin <Brice.Goglin@ens-lyon.org>,
	netdev@vger.kernel.org, Divy Le Ray <divy@chelsio.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.go2.pl ([193.17.41.42]:37945 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755932AbXGFJAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 05:00:05 -0400
Content-Disposition: inline
In-Reply-To: <20070705122847.GA13368@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 05, 2007 at 04:28:47PM +0400, Evgeniy Polyakov wrote:
> Hi, Jarek.
> 
> On Thu, Jul 05, 2007 at 02:28:50PM +0200, Jarek Poplawski (jarkao2@o2.pl) wrote:
> > I wonder if it's very unsound to think about a one way list
> > of destructors. Of course, not owners could only clean their
> > private allocations. Woudn't this save some skb clonning,
> > copying or adding new fields for private infos?
> 
> There should not be any additional allocations, since they are very
> slow, that part of mbuf is really horrible for performance - openbsd
> hackers removed additional allocation of mbuf tag in PF code during the
> last hackathon, which doubled its performance, that is why skb has only 
> one control structure and data area, which incorporates additional 
> control information, thus there is no need for multiple destructors.

I'd like to add a few words about performance-way-thinking.

Some time ago I've read mainly networking/admins lists. One of the
most often questions was: what should I choose linux or bsd? And
very often bsd was praised for better performance, but almost
always linux was advised as more universal (even by people who
said they use both).

BSDs were sometimes recommended for specific jobs like mail etc.
but usually linux better fitted the needs. Especially well linux
appeared for an internet gateway/router/firewall/antispam thing,
and the main reasons were: netfilter with additional, unofficial
patches e.g. l-7 filtering and imq. BSD was no option here.

Some time later, reading this list, I've found many people almost
hate netfilter for performance. You can imagine how l-7 adds to
this "performance". IMQ isn't even mentioned here - looks like
some dirty word (lack of programmers affects it's quality and
doesn't help linux too). But it's nothing near performance too.
I can also remember quite a lot of questions like: how can I avoid
tc/ip and do this with netfilter only?

Probably the most of the readers/writers were small or middle
networks admins (but quite often servicing hundreds or thousans
boxes too), probably not always advanced enough, but you know what,
they made 99% of interested. So, I understand something could've
changed with voip, and there are high performance linux servers
too (their admins have never heard of imq), and probably thinking
about them could pay off better, but there could be some cost
of such thinking too.

Regards,
Jarek P.

PS: in my opinion lack of linux performance wasn't even the second
most often asked question there; rather this: why my new & beautiful
linux box sometimes lockups?
