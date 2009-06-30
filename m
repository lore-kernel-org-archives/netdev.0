From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tc filter flow hash question
Date: Tue, 30 Jun 2009 09:56:28 +0000
Message-ID: <20090630095628.GB8592@ff.dom.local>
References: <20090630085706.GD5589@ff.dom.local> <4A49D872.5050403@bigtelecom.ru> <20090630092344.GA8592@ff.dom.local> <4A49DF97.6090608@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:49527 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753296AbZF3J4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 05:56:31 -0400
Received: by fxm18 with SMTP id 18so12991fxm.37
        for <netdev@vger.kernel.org>; Tue, 30 Jun 2009 02:56:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A49DF97.6090608@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 30, 2009 at 01:49:11PM +0400, Badalian Vyacheslav wrote:
...
> This example not approach? 
> 
> tc qdisc add dev eth0 root handle 1 htb default 7
> tc class add dev eth0 parent 1: classid 1:7 htb rate 500mbit ceil 1000mbit prio 3
> tc qdisc add dev eth0 parent 1:7 handle 10: sfq perturb 10
> 
> # all traffic go to class 1-7.
> 
> # Try group traffic by "src,dst" key
> 
> tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys src,dst
> 
> # all traffic dropped

Try:
tc filter add dev eth0 protocol ip parent 10: handle 2 flow hash keys src,dst divisor 1024

Jarek P.
> >   
> >>> Here are some hints (if we don't mention google ;-)
> >>> http://git.kernel.org/?p=linux/kernel/git/stable/linux-2.6.29.y.git;a=commitdiff;h=e5dfb815181fcb186d6080ac3a091eadff2d98fe
> >>>
> >>> Regards,
> >>> Jarek P
