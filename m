From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 16:31:44 +0200
Message-ID: <200910261631.44666.opurdila@ixiacom.com>
References: <200910252158.53921.opurdila@ixiacom.com> <4AE53382.8020308@gmail.com> <OF703F980D.0971407E-ON6525765B.00458CCA-6525765B.00481976@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:27546 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751285AbZJZOel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 10:34:41 -0400
In-Reply-To: <OF703F980D.0971407E-ON6525765B.00458CCA-6525765B.00481976@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 October 2009 15:07:31 you wrote:
> Eric Dumazet wrote on 10/26/2009 10:58:34 AM:
> > In fact, new10 should be the 'perfect' hash for the "eth%d"
> > netdev use, not jhash (way more expensive in cpu cycles BTW)
> >
> > Most linux machines in the world have less than 10 interfaces, jhash
> > would be really overkill.
> >
> >
> > Thanks
> >
> >
> > [PATCH net-next-2.6] netdev: better dev_name_hash
> 
> Changing Eric's test program to pass a multiplier to string_hash()
> and calling string_hash with multipler=<2 - 63> confirms that 10
> is almost always the best number for varying netdev names. I print
> the number of times perfect 64 was scored, and for most passed
> device names, the best is for n=10, followed by n=5 and others.
> Almost the worst was n=31, slightly better was n=17.
> 
> But other variables matter too, like fewer entries (4K or 1K) but
> above values for are still better compared to n=31.
> 

Hmm, I've found out that it very much depends on the name as well:

0 - orig, 1 - jhash, 2 - new10, 3 - new17, 4 - new31

$ ./dev_name_hash ixint 16000 0 16
score 24741
$ ./dev_name_hash ixint 16000 1 16
score 17949
$ ./dev_name_hash ixint 16000 2 16
score 16000
$ ./dev_name_hash ixint 16000 3 16
score 16715
$ ./dev_name_hash ixint 16000 4 16
score 18125


$ ./dev_name_hash ixunc 16000 0 16
score 24741
$ ./dev_name_hash ixunc 16000 1 16
score 17904
$ ./dev_name_hash ixunc 16000 2 16
score 22180
$ ./dev_name_hash ixunc 16000 3 16
score 17065
$ ./dev_name_hash ixunc 16000 4 16
score 18038
