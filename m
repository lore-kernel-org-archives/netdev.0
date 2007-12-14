From: Glen Turner <gdt@gdt.id.au>
Subject: Re: Packet per Second
Date: Sat, 15 Dec 2007 09:01:53 +1030
Message-ID: <1197671513.5973.10.camel@andromache>
References: <nemoFri121407105527@flis.man.torun.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@osdl.org
To: =?ISO-8859-1?Q?Fl=E1vio?= Pires <flavio.defreitas@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:38025 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751951AbXLNWtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 17:49:49 -0500
In-Reply-To: <nemoFri121407105527@flis.man.torun.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2007-12-14 at 15:34 +0000, Fl=C3=A1vio Pires wrote:

> Well, I work on an ISP and we have a linux box acting as a
> bridge+firewall. With this bridge+firewall we control the packet rate
> per second from each client and from our repeaters. But I can`t
> measure the packet rate per IP. Is there any tool for this?

The usual approach is to generate NetFlow records -- there are
a number of Linux tools for this. Collect them with a collector
(flow-tools being a common choice). Then have a Perl script
which reads the flow records, processes them whichever way you
desire, and drops the result into a rrdtool file (there are modules
for both reading the flow-tools data and outputing in the rrdtool
format). The rrdtool utilities have a limited range of graphs,
but there is a huge selection of graphing packages from other
authors for rrdtool-stored data (Drraw, etc).  Flow-tools also
has some third-party analysis tools, some of those have good
"top talker" statistics.

This is a lot of work, since you are really putting a complete
measurement infrastructure in place to get the one statistic
you desire.  But I'd encourage you to do that, since knowing
one statistic usually leads to further questions of the data.

--=20
Glen Turner, Senior Network Engineer
Australia's Academic & Research Network    www.aarnet.edu.au

