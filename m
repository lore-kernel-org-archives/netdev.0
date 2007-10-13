From: jamal <hadi@cyberus.ca>
Subject: Re: tc_verd vs. skb_clone
Date: Sat, 13 Oct 2007 04:04:26 -0400
Message-ID: <1192262666.4434.16.camel@localhost>
References: <20071012140026.GA27761@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:28886 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbXJMIEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 04:04:30 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1147173wxd
        for <netdev@vger.kernel.org>; Sat, 13 Oct 2007 01:04:29 -0700 (PDT)
In-Reply-To: <20071012140026.GA27761@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-12-10 at 22:00 +0800, Herbert Xu wrote:
> Hi Jamal:
> 
> I was wondering why we're not copying tc_verd as is in skb_clone.
> In particular, this makes pskb_copy behave differently compared
> to skb_clone and I can't find a justificatino for it.
> 
> Any ideas?

In the case of an action branching (from a graph), they clone. In the
case they want to trample on an skb, they copy; otherwise it continues
processing in the graph with none of the above. In the clone case,
certain metadata needs reseting (like the "it is ok to munge on this
packet" to "it is _not_ ok to munge on it" etc). We allow the copy case 
leeway to do whatever it wants since it is going to tranple on the skb
and therefore reset nothing.
Would something more verbose in Documentation/net help to make this
clear?

If it is causing trouble, then one idea would be to move the resetting
to a wrapper function which calls clone first and then resets the other
fields. All actions currently cloning would need to be mod-ed to use
that call.

> Also we don't seem to copy iif in copy_skb_header.

I cant think of a good reason why it shouldnt be copied or recall
whether thats how its been from the begining. The reason probably it
hasnt mattered so far is everything that needs to write the iif never
copies.

cheers,
jamal

