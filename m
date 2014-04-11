From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Should linux send netlink message as it is deleting that
 routing entry?
Date: Fri, 11 Apr 2014 11:30:42 -0700
Message-ID: <20140411113042.4328c39c@nehalam.linuxnetplumber.net>
References: <534654FE.3040804@gmail.com>
	<5347B2C4.6040103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	ebiederm@xmission.com, ja@ssi.bg,
	"Yang, Zhangle (Eric)" <Zhangle.Yang@windriver.com>,
	"Tao, Yue" <Yue.Tao@windriver.com>,
	"Zadoyan, Grant" <Grant.Zadoyan@windriver.com>,
	eric.dumazet@gmail.com, socketcan@hartkopp.net,
	hannes@stressinduktion.org, cwang@twopensource.com
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:49841 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807AbaDKSaq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 14:30:46 -0400
Received: by mail-pb0-f44.google.com with SMTP id rp16so5727672pbb.31
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 11:30:45 -0700 (PDT)
In-Reply-To: <5347B2C4.6040103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Apr 2014 17:15:48 +0800
zhuyj <zyjzyj2000@gmail.com> wrote:

> > With ubuntu 12.04, I run the following to reproduce this defect.
> >
> > 1) Configure an interface
> > ifconfig eth1 150.0.0.1/24 up
> >
> > 2) Add routing entry via that interface address
> > route add -net 200.0.0.0/24 gw 150.0.0.1
> >
> > 3) Change the ip address on that interface as shown below.
> > ifconfig eth1 151.0.0.1/24 up
> >
> > 4) Check netlink messages with "ip monitor all". There is no route 
> > delete netlink message.
> >

With IPv4 there are several cases where there is a non-notified
implicit route withdrawal. This is not something that can be fixed.
There are two issues:
 1. with large backbone size route tables (ie 1M routes), the number
    of notification messages becomes a bottleneck and would be unreliable
 2. the existing routing daemons (quagga, bird, etc) all understand/expect
    the existing semantics
