From: Thomas Graf <tgraf@infradead.org>
Subject: Re: [HELP] for using class group classifier network controller
Date: Mon, 15 Jun 2009 06:30:20 -0400
Message-ID: <20090615103020.GA8894@bombadil.infradead.org>
References: <4C86297B4AC6554B8BA018F0806590CE01C8AFA5@email1> <20090615113609.db5c0613.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?utf-8?B?6rmA7J6s7Je0?= <gauri@etri.re.kr>,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53595 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbZFOKaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2009 06:30:20 -0400
Content-Disposition: inline
In-Reply-To: <20090615113609.db5c0613.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 15, 2009 at 11:36:09AM +0900, Minoru Usui wrote:
> Hi, Cheiyol
> 
> > # classid 1:10
> > 
> > echo 0x1000A > /dev/cpuctl/foo/net_cls.classid
> > 
> > #classid 1:20
> > 
> > echo 0x10014 > /dev/cpuctl/bob/net_cls.classid
> 
> (snip)
> 
> > # add class 1:10 for foo group
> > 
> > $TC class add dev eth0 parent 1:0 classid 1:10 htb rate 50mbit
> > 
> > # add class 1:20 for bob group
> > 
> > $TC class add dev eth0 parent 1:0 classid 1:20 htb rate 30mbit
> > 
> > # default class
> > 
> > $TC class add dev eth0 parent 1:0 classid 1:30 htb rate 10mbit
> 
> In class ID to use TC, both a major number and a minor number are hexadecimal.
> So 1:10 equals 0x00010010.
> 
> I think, you should set 0x10010 to net_cls.classid if you classify to 1:10.

That's right, both net_cls.classid and tc use integers in hexadecimal form
for both, printing and parsing.

10:10 -> 0x100010
10:20 -> 0x100020

This seems to be the weak point regarding usability that's why I like
Minoru Usui's patch so much. It would no longer be necessary to really
understand the internals of classids etc.
