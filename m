From: David Miller <davem@davemloft.net>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Mon, 19 Dec 2016 20:56:46 -0500 (EST)
Message-ID: <20161219.205646.1955469060856026212.davem@davemloft.net>
References: <1481928610.17731.0@smtp.office365.com>
        <e32b5375-38fb-1fd8-d97a-bf740e368205@stressinduktion.org>
        <286A21B1-2A15-4DDF-B334-A016DA3D52EA@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, tom@herbertland.com,
        kraigatgoog@gmail.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org
To: jbacik@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54794 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756863AbcLTB4s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 20:56:48 -0500
In-Reply-To: <286A21B1-2A15-4DDF-B334-A016DA3D52EA@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>
Date: Sat, 17 Dec 2016 13:26:00 +0000

> So take my current duct tape fix and augment it with more
> information in the bind bucket?  I'm not sure how to make this work
> without at least having a list of the binded addrs as well to make
> sure we are really ok.  I suppose we could save the fastreuseport
> address that last succeeded to make it work properly, but I'd have
> to make it protocol agnostic and then have a callback to have the
> protocol to make sure we don't have to do the bind_conflict run.  Is
> that what you were thinking of?  Thanks,

So there isn't a deadlock or lockup here, something is just running
really slow, right?

And that "something" is a scan of the sockets on a tb list, and
there's lots of timewait sockets hung off of that tb.

As far as I can tell, this scan is happening in
inet_csk_bind_conflict().

Furthermore, reuseport is somehow required to make this problem
happen.  How exactly?
