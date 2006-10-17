From: "Eric Barton" <eeb@bartonsoftware.com>
Subject: RE: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 13:50:04 +0100
Message-ID: <021a01c6f1ea$c45e1820$0281a8c0@ebpc>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'David Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.blueyonder.co.uk ([195.188.213.7]:1720 "EHLO
	smtp-out4.blueyonder.co.uk") by vger.kernel.org with ESMTP
	id S1750738AbWJQMuH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 08:50:07 -0400
To: "'Evgeniy Polyakov'" <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy,

> You can use existing skb destructor and appropriate reference
> counter is already there. In your own destructor you need to
> call old one of course, and it's type can be determined from
> the analysis of the headers and skb itself (there are not so
> much destructor's types actually).  If that level of
> abstraction is not enough, it is possible to change
> skb_release_data()/__kfree_skb() so that it would be possible
> in skb->destructor() to determine if attached pages will be
> freed or not.

Yes absolutely.  My first thought was to use the skbuf destructor
but I was paranoid I might screw up the destructor stacking.
Maybe I should have been braver?

Since the callback descriptor needs to track the pages in
skb_shinfo() rather than the skbuf itself, it seemed "natural"
to make skb_release_data() the trigger.

> Existing sendfile() implementation is synchronous, it does not
> require async callback. 

Is it not true that you cannot know when it is safe to overwrite
pages sent in this way?

> skbs are allocated from own cache, and the smaller it is, the better.

As I mentioned in another reply, skbs are indeed allocated from
their own cache, but skb_shinfo() is allocated contiguously with
the packet header using kmalloc.

-- 

                Cheers,
                        Eric


