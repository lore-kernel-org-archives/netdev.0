From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 22:39:01 +0200
Message-ID: <1340829541.26242.90.camel@edumazet-glaptop>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
	 <1340823810.26242.81.camel@edumazet-glaptop>  <4FEB6B64.5060708@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59341 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab2F0UjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 16:39:07 -0400
Received: by bkcji2 with SMTP id ji2so1433221bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 13:39:05 -0700 (PDT)
In-Reply-To: <4FEB6B64.5060708@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 13:21 -0700, Rick Jones wrote:

> It is a question of the speed of the communications more than the 
> bitness of the processor no?

Why ?

In 2012 or 2013, 64bits kernels are the norm, and 32bit the exception.

Should we add complex code to l2tp just for being able to run it on
32bit kernels with 64bit stats ?

Considering this code is buggy at the v1 & v2, I am really wondering.

All sane SNMP applications are ready to cope with 32bits counters
wrapping.

Machines that could wrap the 32bit counter several times per second are
probably running on 64bit kernels.

Also percpu stats are overkill unless a device is really meant to be
used in // by many cpus.
