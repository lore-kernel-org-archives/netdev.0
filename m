From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sat, 22 Apr 2006 15:29:58 +0200
Message-ID: <200604221529.59899.ioe-lkml@rameria.de>
References: <Pine.LNX.4.44L0.0604201819040.19330-100000@lifa01.phys.au.dk> <200604211852.47335.netdev@axxeo.de> <20060422114846.GA6629@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ingo Oeser <netdev@axxeo.de>,
	"David S. Miller" <davem@davemloft.net>, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeus1.kernel.org ([204.152.191.4]:9924 "EHLO zeus1.kernel.org")
	by vger.kernel.org with ESMTP id S1751095AbWDVTv5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Apr 2006 15:51:57 -0400
Received: from smtprelay01.ispgateway.de (smtprelay01.ispgateway.de [80.67.18.13])
	by zeus1.kernel.org (8.13.1/8.13.1) with ESMTP id k3MDWqGO000550
	for <netdev@vger.kernel.org>; Sat, 22 Apr 2006 13:32:53 GMT
To: =?iso-8859-1?q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>
In-Reply-To: <20060422114846.GA6629@wohnheim.fh-wedel.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi J=F6rn,

On Saturday, 22. April 2006 13:48, J=F6rn Engel wrote:
> Unless I completely misunderstand something, one of the main points o=
f
> the netchannels if to have *zero* fields written to by both producer
> and consumer.=20

Hmm, for me the main point was to keep the complete processing
of a single packet within one CPU/Core where this is a non-issue.

> Receiving and sending a lot can be expected to be the=20
> common case, so taking a performance hit in this case is hardly a goo=
d
> idea.

There is no hit. If you receive/send in bursts you can simply aggregate
them until a certain queueing threshold.=20

The queue design outlined can split the queueing in reserve and commit =
stages,
where the producer can be told how much in can produce and the consumer=
 is
told  how much it can consume.=20

Within their areas the producer and consumer can freely move around.
So this is not exactly a queue, but a dynamic double buffer :-)

So maybe doing queueing with the classic head/tail variant is better he=
re,
but the other variant might replace it without problems and allows
for some nice improvements.


Regards

Ingo Oeser
