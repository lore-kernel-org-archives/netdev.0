From: Anirban Sinha <asinha@zeugmasystems.com>
Subject: Re: Kernel oops when clearing bgp neighbor info with TCP MD5SUM
 enabled
Date: Thu, 8 Oct 2009 16:33:47 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0910081622400.18315@sleet.zeugmasystems.local>
References: <Pine.LNX.4.64.0910081514050.18315@sleet.zeugmasystems.local>
 <20091008.155429.02850661.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeugmasystems.com ([70.79.96.174]:20733 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757866AbZJHXe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 19:34:29 -0400
In-Reply-To: <20091008.155429.02850661.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

Thanks for responding.

> > We are noticing a kernel OOPS on 2.6.26 kernel when we issue the command
> > "clear ip bgp <bgp-peer-ip>" on Quagga BGP routing software.
>
> You will need to update your kernel, there have been many TCP
> MD5 bug fixes since 2.6.26
>

Sigh ... wish that were that easy! Anyway, as far as I could, I have tried to
apply the upstream patches that seemed relevant to TCP MD5SUM. Am I missing
some other patches? It will be great if someone can point me to any patch that
I might be missing related to the TCP MD5SUM support.

I applied the following patches:

(a)

author	Adam Langley <agl@imperialviolet.org>
	Sat, 19 Jul 2008 07:01:42 +0000 (00:01 -0700)
committer	David S. Miller <davem@davemloft.net>
	Sat, 19 Jul 2008 07:01:42 +0000 (00:01 -0700)
commit	49a72dfb8814c2d65bd9f8c9c6daf6395a1ec58d
tree	38804d609f21503573bbdd8bb9af38df99275ff5	tree | snapshot
parent	845525a642c1c9e1335c33a274d4273906ee58eb	commit | diff
tcp: Fix MD5 signatures for non-linear skbs

Currently, the MD5 code assumes that the SKBs are linear and, in the case
that they aren't, happily goes off and hashes off the end of the SKB and
into random memory.

Reported by Stephen Hemminger in [1]. Advice thanks to Stephen and Evgeniy
Polyakov. Also includes a couple of missed route_caps from Stephen's patch
in [2].

[1] http://marc.info/?l=linux-netdev&m=121445989106145&w=2
[2] http://marc.info/?l=linux-netdev&m=121459157816964&w=2

Signed-off-by: Adam Langley <agl@imperialviolet.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: David S. Miller <davem@davemloft.net>

(b)

author	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Fri, 18 Apr 2008 03:45:16 +0000 (12:45 +0900)
committer	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Wed, 11 Jun 2008 18:46:30 +0000 (03:46 +0900)
commit	9501f9722922f2e80e1f9dc6682311d65c2b5690
tree	ca8195e04ea63e8273801030ce26527fe5a8a7c7	tree | snapshot
parent	8d26d76dd4a4c87ef037a44a42a0608ffc730199	commit | diff

tcp md5sig: Let the caller pass appropriate key for
tcp_v{4,6}_do_calc_md5_hash().

As we do for other socket/timewait-socket specific parameters,
let the callers pass appropriate arguments to
tcp_v{4,6}_do_calc_md5_hash().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

(c)

author	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Thu, 17 Apr 2008 04:19:16 +0000 (13:19 +0900)
committer	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Wed, 11 Jun 2008 17:38:20 +0000 (02:38 +0900)
commit	8d26d76dd4a4c87ef037a44a42a0608ffc730199
tree	884ff53a83e460aa3f1837cc336a5a34f364156e	tree | snapshot
parent	076fb7223357769c39f3ddf900bba6752369c76a	commit | diff

tcp md5sig: Share most of hash calcucaltion bits between IPv4 and IPv6.
We can share most part of the hash calculation code because
the only difference between IPv4 and IPv6 is their pseudo headers.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

(d)

author	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Thu, 17 Apr 2008 03:48:12 +0000 (12:48 +0900)
committer	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Wed, 11 Jun 2008 17:38:19 +0000 (02:38 +0900)

commit	076fb7223357769c39f3ddf900bba6752369c76a
tree	db75c2af3bf71cda4d0cccd6ebcfa8d1a62c3620	tree | snapshot
parent	7d5d5525bd88313e6fd90c0659665aee5114bc2d	commit | diff

tcp md5sig: Remove redundant protocol argument.
Protocol is always TCP, so remove useless protocol argument.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

(e)

author	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Thu, 17 Apr 2008 03:29:53 +0000 (12:29 +0900)
committer	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
	 Wed, 11 Jun 2008 17:38:18 +0000 (02:38 +0900)
commit	7d5d5525bd88313e6fd90c0659665aee5114bc2d
tree	41517e753220261c8cc46d975977cfd711892f6c	tree | snapshot
parent	81b302a321a0d99ff172b8cb2a8de17bff2f9499	commit | diff

tcp md5sig: Share MD5 Signature option parser between IPv4 and IPv6.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>


Cheers,

Ani
