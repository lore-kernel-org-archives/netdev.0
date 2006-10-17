From: "Eric Barton" <eeb@bartonsoftware.com>
Subject: RE: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 01:53:02 +0100
Message-ID: <019c01c6f186$99d0d6b0$0281a8c0@ebpc>
References: <20061016.135222.78711520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out3.blueyonder.co.uk ([195.188.213.6]:33702 "EHLO
	smtp-out3.blueyonder.co.uk") by vger.kernel.org with ESMTP
	id S1030189AbWJQAw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Oct 2006 20:52:57 -0400
To: "'David Miller'" <davem@davemloft.net>
In-Reply-To: <20061016.135222.78711520.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

> Also, the correct mailing list to get to the networking developers
> is netdev@vger.kernel.org.  "linux-net" is for users.

Noted.

> Finally, I very much doubt you have much chance getting this
> change in, the infrastructure is implemented in a very ad-hoc
> fashion and it takes into consideration none of the potential
> other users of such a thing.  

Are you referring to the absence of a callback argument other than the
callback descriptor itself?  It seemed natural to me to contain the
descriptor in whatever state the higher-level protocol associates with the
message it's sending, and to derive this from the descriptor address in the
callback.

If this isn't what you mean, could you explain?  I'm not at all religious
about it.

> And these days we're trying to figure
> out how to eliminate skbuff and skb_shared_info struct members
> whereas you're adding 16-bytes of space on 64-bit platforms.

Do you think the general concept of a zero-copy completion callback is
useful?

If so, do you have any ideas about how to do it more economically?  It's 2
pointers rather than 1 to avoid forcing an unnecessary packet boundary
between successive zero-copy sends.  But I guess that might not be hugely
significant since you're generally sending many pages when zero-copy is
needed for performance.  Also, (please correct me if I'm wrong) I didn't
think this would push the allocation over to the next entry in
'malloc_sizes'.

                Cheers,
                        Eric


