From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: AIM9 regression
Date: Fri, 31 Oct 2008 16:57:48 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810311619270.23792@wrl-59.cs.helsinki.fi>
References: <20080924051237.GA6173@gondor.apana.org.au>
 <20080923.221831.126801015.davem@davemloft.net> <20080924081603.08a5f808@extreme>
 <20080924.123657.217162945.davem@davemloft.net>
 <Pine.LNX.4.64.0809291252490.1034@wrl-59.cs.helsinki.fi>
 <48E0EC13.3060907@linux-foundation.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1790493498-1225463309=:23792"
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Netdev <netdev@vger.kernel.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35966 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbYJaO5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 10:57:51 -0400
In-Reply-To: <48E0EC13.3060907@linux-foundation.org>
Content-ID: <Pine.LNX.4.64.0810311630390.23792@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1790493498-1225463309=:23792
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0810311630391.23792@wrl-59.cs.helsinki.fi>

On Mon, 29 Sep 2008, Christoph Lameter wrote:

> Ilpo Järvinen wrote:
> 
> > ...I was thinking earlier to answer "time?", but now once been there, it 
> > seems that more time is more appropriate... So far I haven't been able to 
> > find a way to create a reproducable serie of result numbers with aim9 
> > tcp_test... it seems that the results vary within that (at least) 20% 
> > margin. Can Christoph actually get stable numbers out of it with 27-rcs
> > (I haven't extensively tested .22 yet with long test durations but it 
> > seems that same problem occurs with it as well if short tests were used)?
> 
> Results fluctuate between 10 - 25%. The problem occurs with the short
> durations as well. If this is due to the additional code complexity in later
> kernels as we suspect then it may be an issue with cpu cache effectiveness.
> 
> Going to 64 bit binaries also yields a significant hit (as high as 30%) which
> also indicates caching issues.
> 
> Both 64 bit kernels and later kernels cause the variability of results to
> increase. 64 bit has double the effect than a 2.6.27 kernel. All indications
> of cpu caching issues. The L1 cache may become ineffective due to the
> increased cache footprint.

I experimented with it some and changed tcp_test to bind into supplied 
port instead of relying on the port allocator randomness, both server and 
client port were do like that. However, I had to turn tcp_tw_recycle on to 
get the test to actually return instead of -ESOMETHING. In addition I did
sync & drop_caches before each run (I'm not sure if it did actually reduce 
variantion a bit or did I just imagine, I'd expect it to damp test 
harness caused artifacts if it did something) + sleep 20 before each 20 
seconds test.

Port allocator could be benchmarked separately if so desired.

Here are my current numbers with 64-bit (nodebug & nonf):

 .22   .28-rc2-gsmthg
          GSO/TSO
         off    on
240700 232398 224194
241187 236722 227610
243940 237388 229472
244367 237469 229576
246134 238569 229680
246211 238680 229999
246400 238693 230262
248761 239076 230404
250934 239107 231404
251203 239152 231562
251572 239215 231912
254158 239863 232744
256407 239912 234017
257329 240022 -EINTR
259560 241352 -EINTR

http://www.cs.helsinki.fi/u/ijjarvin/aim9/res.png

TSO/GSO does modulos every so often but Dave is currently evaluating how 
to get rid of that, discussed here:
http://marc.info/?t=122411618000004&r=1&w=2
...Still some uncertainty where the remaining of Evgeniy's G&TSO off/on 
difference comes from.

2.6.27-rc7 has basically the same numbers as 2.6.28-rc2 though
I accidently had there ftrace on so some extra nops were present.

Still some regression to attack, but there seems to considerably
less than 20% when testing for net_random()'s output is removed.

-- 
 i.
---696208474-1790493498-1225463309=:23792--
