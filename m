From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH net-next 00/11] netns: don't switch namespace while
 creating kernel sockets
Date: Sat, 9 May 2015 09:13:39 +0800
Message-ID: <20150509011339.GA19116@gondor.apana.org.au>
References: <1430988770-28907-1-git-send-email-ying.xue@windriver.com>
 <87wq0kcqlm.fsf@x220.int.ebiederm.org>
 <20150508140733.GA13325@gondor.apana.org.au>
 <87sib76kef.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>, netdev@vger.kernel.org,
	cwang@twopensource.com, xemul@openvz.org, davem@davemloft.net,
	eric.dumazet@gmail.com, maxk@qti.qualcomm.com,
	stephen@networkplumber.org, tgraf@suug.ch,
	nicolas.dichtel@6wind.com, tom@herbertland.com,
	jchapman@katalix.com, erik.hugne@ericsson.com,
	jon.maloy@ericsson.com, horms@verge.net.au
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:52048 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbbEIBOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2015 21:14:02 -0400
Content-Disposition: inline
In-Reply-To: <87sib76kef.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 08, 2015 at 12:36:56PM -0500, Eric W. Biederman wrote:
>
> At the same time while a network namespace remains discoverable we might
> be using it in small ways.  So I am wondering if this is the right
> approach.
> 
> It really is invalid for a network namespace init routine to grab the
> reference count of it's network namespace (thus making the network
> namespace unfreeable).  So I am wondering if perhaps all we need to do
> is find a clean refactoring of the socket code so this case does not
> come up at all.
> 
> Perhaps just a flag that says this is a kernel socket so don't get/put
> the refcount on the network namespace.  

No this line of thinking is what led us into the hole in the
first place.

Really it's perfectly valid for the init function to want to
take a reference on net.  For all we know it might be a temporary
reference taken by a third party.  It doesn't even have to be a
socket.

We must hide this subtlety from ops implementors since they have
no knowledge of our implementation.  Expecting them to deal with
this is going to result in bugs, and we have already had multiple
bugs in this area.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
