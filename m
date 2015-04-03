From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] jhash: Update jhash_[321]words functions to
 use correct initval
Date: Fri, 03 Apr 2015 12:52:54 -0400 (EDT)
Message-ID: <20150403.125254.1535588221416703623.davem@davemloft.net>
References: <20150331211826.1133.19645.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbbDCQw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 12:52:56 -0400
In-Reply-To: <20150331211826.1133.19645.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Tue, 31 Mar 2015 14:19:10 -0700

> Looking over the implementation for jhash2 and comparing it to jhash_3words
> I realized that the two hashes were in fact very different.  Doing a bit of
> digging led me to "The new jhash implementation" in which lookup2 was
> supposed to have been replaced with lookup3.
> 
> In reviewing the patch I noticed that jhash2 had originally initialized a
> and b to JHASH_GOLDENRATIO and c to initval, but after the patch a, b, and
> c were initialized to initval + (length << 2) + JHASH_INITVAL.  However the
> changes in jhash_3words simply replaced the initialization of a and b with
> JHASH_INITVAL.
> 
> This change corrects what I believe was an oversight so that a, b, and c in
> jhash_3words all have the same value added consisting of initval + (length
> << 2) + JHASH_INITVAL so that jhash2 and jhash_3words will now produce the
> same hash result given the same inputs.
> 
> Fixes: 60d509c823cca ("The new jhash implementation")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

This looks correct to me, applied, thanks!
