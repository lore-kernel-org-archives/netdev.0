From: Paul Menage <menage@google.com>
Subject: Re: [Devel] Re: [PATCH 1/1] cls_cgroup: unify classid syntax to tc
Date: Thu, 11 Jun 2009 22:06:00 -0700
Message-ID: <6599ad830906112206n745fb0dw19cdb75d7c40b2a4@mail.gmail.com>
References: <20090611180555.f2c76568.usui@mxm.nes.nec.co.jp>
	 <20090611.021347.142243970.davem@davemloft.net>
	 <20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, tgraf@suug.ch,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	hadi@cyberus.ca, jarkao2@gmail.com
To: Minoru Usui <usui@mxm.nes.nec.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.13]:11213 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310AbZFLFGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 01:06:01 -0400
Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id n5C562Sk024054
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 22:06:02 -0700
Received: from pxi26 (pxi26.prod.google.com [10.243.27.26])
	by zps78.corp.google.com with ESMTP id n5C560xV025106
	for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 22:06:01 -0700
Received: by pxi26 with SMTP id 26so17913pxi.23
        for <netdev@vger.kernel.org>; Thu, 11 Jun 2009 22:06:00 -0700 (PDT)
In-Reply-To: <20090612124028.fe4c2100.usui@mxm.nes.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2009 at 8:40 PM, Minoru Usui<usui@mxm.nes.nec.co.jp> wrote:
>
> It's true. If my patch applied, old syntax can't use.
> But I think compatibility is important, too.
> So I'll make a new patch which can use both old and new syntax, when we write classid to net_cls.classid file.
>
> Present implementation is an asymmetry with read and write.(read: decimal, write: hexadecimal)

You can write the classid value in decimal too, or even octal - it
just uses strtoull() to convert the string to an integer, so
0x-prefixed hex values are handled automatically.

>
> If it's ok, I'd like to be able to use tc syntax(X:Y style),
> because cls_cgroup's purpose is select class which create by tc command.
> tc command can only use classid syntax X:Y style, so we should be able to use X:Y style to cls_cgroup.

We should keep it as it is - purely apart from compatibility issues,
there's no need to introduce the complexity of the tc interface into
the cls_cgroup kernel code. When a cgroup control file represents a
simple integer, then it should be exposed as such.

Paul
