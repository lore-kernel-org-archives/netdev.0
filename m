From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH next-next-2.6] netdev: better dev_name_hash
Date: Mon, 26 Oct 2009 17:52:51 +0200
Message-ID: <200910261752.51784.opurdila@ixiacom.com>
References: <200910252158.53921.opurdila@ixiacom.com> <200910261631.44666.opurdila@ixiacom.com> <4AE5B84E.8040505@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:21590 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753078AbZJZPzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 11:55:45 -0400
In-Reply-To: <4AE5B84E.8040505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 26 October 2009 16:55:10 you wrote:
> 
> This is because you chose a 65536 slots hash table, to store 16000 elements
> 
> The ideal function should be :
> 
> $ ./dev_name_hash ixunc 16000 5 16
> score 16000
> 
> unsigned int dev_name_hash_new10bis(const char *name)
> {
> 	unsigned hash = 0;
> 	int len = strnlen(name, IFNAMSIZ);
> 	int i;
> 
> 	for (i = 0; i < len; ++i)
> 		hash = 10 * hash + (name[i] - '0');
> 	return hash;
> }
> 

Eric, thanks a lot for your help. This is turning into a very instructive 
thread for me :)

10bis performs better for ixunc but interestingly performs worse for ixint 
now. I also get mixed results for the two when using other names like ppp or 
gtp.

2 - new10, 3 - new10bis

score 49852
$ ./dev_name_hash ixint 32000 3 14
score 53194
$ ./dev_name_hash ixunc 32000 2 14
score 55232
$ ./dev_name_hash ixunc 32000 3 14
score 48168

> But should we really care ?

I'm just testing various common cases we use here ({ixint,ixunc,gtp,ppp,gre} 
{1000,16000,32000,128000} {14,16}). 

Ideally we want a hash function that performs better in all cases  - but I 
understand that it may not be possible.

I will play more with it and see if I can come up with something better, but 
in any case the new{10,10bis,17,31} performs much better than full_name_hash 
and most of the time better that jhash .
