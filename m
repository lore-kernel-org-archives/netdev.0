From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 09:45:30 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0908250944160.5972@gentwo.org>
References: <alpine.DEB.1.10.0908171548040.20399@gentwo.org>  <4A89C026.4030402@us.ibm.com>  <alpine.DEB.1.10.0908171642500.20399@gentwo.org>  <1250545839.25939.21.camel@w-sridhar.beaverton.ibm.com>  <alpine.DEB.1.10.0908171813070.15956@gentwo.org>
 <1250549034.25939.30.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908171848370.15956@gentwo.org> <4A931ED3.1090206@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Nivedita Singhvi <niv@us.ibm.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.ultrahosting.com ([74.213.175.253]:33677 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753480AbZHYNpe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 09:45:34 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 35ADC82CEA0
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 09:46:28 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MbMzZld3CpGP for <netdev@vger.kernel.org>;
	Tue, 25 Aug 2009 09:46:28 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id AB44382CEA1
	for <netdev@vger.kernel.org>; Tue, 25 Aug 2009 09:46:23 -0400 (EDT)
In-Reply-To: <4A931ED3.1090206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2009, Eric Dumazet wrote:

> Thread model: posix
> gcc version 4.4.1 (GCC)
> # pwd
> /opt/src/lldiag-0.14
> # make
> gcc -Wall -omcast mcast.c -lrt -lm
> mcast.c: In function ?set_ip?:
> mcast.c:121: warning: implicit declaration of function ?htons?
> mcast.c: In function ?build_pattern_array?:
> mcast.c:168: warning: implicit declaration of function ?htonl?
> /tmp/cc4sYCDr.o: In function `lock':
> mcast.c:(.text+0xcad): undefined reference to `__sync_fetch_and_add_4'
> collect2: ld returned 1 exit status
> make: *** [mcast] Error 1
>
>
> I have no idea where is defined sync_fetch_and_add

Its a GCC builtin for x86 sigh. Ok will put out 0.15 that disables their
use by default.

