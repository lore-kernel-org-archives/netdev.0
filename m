From: David Miller <davem@davemloft.net>
Subject: Re: SO_BINDTODEVICE mismatch with man page & comments.
Date: Fri, 14 Sep 2007 15:29:12 -0700 (PDT)
Message-ID: <20070914.152912.74747426.davem@davemloft.net>
References: <46DDDFFA.6090705@candelatech.com>
	<20070914.131225.78720330.davem@davemloft.net>
	<46EB071B.9070308@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41677
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755123AbXINW3O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 18:29:14 -0400
In-Reply-To: <46EB071B.9070308@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 14 Sep 2007 15:11:39 -0700

>  From user-space, does this imply that the 'empty string' we use to
> unbind must be at least 4 bytes long, but with the first byte /0?
>
> If so, I think it might be confusing for the comments to say use ""
> to unbind, since that would not be a long enough chunk of memory.
> 
> Maybe something like "Use a character array of at least 4 bytes in
> length with the first byte set to '/0'."

I realize this, I'll try to come up with some clean way to
deal with this.

I don't want to touch that "if (optlen < sizeof(int))" test
at all because it makes all of the logic incredibly complicated
because you then have to forcefully initialize the 'val' and
'valbool' if you bypass reading the int.

> This brings up another issue as well:  What if the device name is "tr1",
> to bind to it we'd have to pass in "tr1/0" and optlen of 4.  Not that this
> is difficult to do, but it does seem like a weird thing to have to do.

You always to account for the NULL termination, thus you always have
to pass in "strlen(X) + 1" as optlen.

But I see your point, and my answer is the same as the first one.

Instead of nit-picking, can you instead try the patch and let me
know if it makes things work for you?

Thanks.

