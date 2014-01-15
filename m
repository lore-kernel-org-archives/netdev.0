From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH net] bpf: do not use reciprocal divide
Date: Wed, 15 Jan 2014 16:10:08 +0100
Message-ID: <20140115151008.GD6638@osiris>
References: <20140113214249.GK6586@order.stressinduktion.org>
 <1389769361.31367.325.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140115080007.GA6638@osiris>
 <1389795398.31367.329.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	darkjames-ws@darkjames.pl, Mircea Gherzan <mgherzan@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Matt Evans <matt@ozlabs.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:60586 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612AbaAOPKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 10:10:16 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <heiko.carstens@de.ibm.com>;
	Wed, 15 Jan 2014 15:10:14 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id DA20F1B0806E
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 15:09:35 +0000 (GMT)
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0FFA1Jk51183784
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 15:10:01 GMT
Received: from d06av04.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0FFAA06011481
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:10:12 -0700
Content-Disposition: inline
In-Reply-To: <1389795398.31367.329.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 15, 2014 at 06:16:38AM -0800, Eric Dumazet wrote:
> On Wed, 2014-01-15 at 09:00 +0100, Heiko Carstens wrote:
> > Are you sure you want to remove the k == 0 check? Is there something
> > else that would prevent a division by zero?
> 
> This is done by factoring the two cases, modulo and divide :
> 
>  vi +553 net/core/filter.c 
> 
>                 /* Some instructions need special checks */
>                 switch (code) {
>                 case BPF_S_ALU_DIV_K:
>                 case BPF_S_ALU_MOD_K:
>                         /* check for division by zero */
>                         if (ftest->k == 0)
>                                 return -EINVAL;
>                         break;

Oh, sorry. I missed the fallthrough.
