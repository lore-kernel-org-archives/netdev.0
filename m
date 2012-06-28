From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Thu, 28 Jun 2012 09:46:47 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F6B@saturn3.aculab.com>
References: <1340859654.26242.201.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Greear" <greearb@candelatech.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Tom Parkin" <tparkin@katalix.com>, <netdev@vger.kernel.org>,
	"James Chapman" <jchapman@katalix.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:56678 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932733Ab2F1Iy7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 04:54:59 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29119-05 for <netdev@vger.kernel.org>;
 Thu, 28 Jun 2012 09:54:55 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1340859654.26242.201.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> [1] : LLTX drivers case 
>    since ndo_start_xmit() can be run concurrently by many cpus, safely
> updating an "unsigned long" requires additional hassle :
> 
>    1) Use of a spinlock to protect the update.
>    2) Use atomic_long_t instead of "unsigned long"
>    3) Use percpu data

4) These are statistics so it shouldn't really matter if
   they are out by a small number.  So the errors
   introduced by unlocked updates can probably be ignored.
   So just use 'unsigned long'.

   Might be worth putting in gcc barriers so that the
   load and store instructions aren't separated too far.

	David
