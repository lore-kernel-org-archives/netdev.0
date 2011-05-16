From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: several packets in a single buffer in Rx
Date: Mon, 16 May 2011 15:59:10 +0300
Message-ID: <BANLkTi=aBLPX7OMKi=sMhT81x-2f6Ci6sQ@mail.gmail.com>
References: <BANLkTimkgtQL1A2A3iAP-UYK2KdDvPmY3Q@mail.gmail.com>
	<BANLkTinb3kaK7_b=47AL+Mb6Zmt9twEM9g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	Johannes Berg <johannes@sipsolutions.net>,
	"Guy, Wey-Yi" <wey-yi.w.guy@intel.com>, guy.cohen@intel.com
To: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60151 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755036Ab1EPM7M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 08:59:12 -0400
In-Reply-To: <BANLkTinb3kaK7_b=47AL+Mb6Zmt9twEM9g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/16 Micha=B3 Miros=B3aw <mirqus@gmail.com>:
> 2011/5/16 Emmanuel Grumbach <egrumbach@gmail.com>:
>> I would like to be able to deliver the same page several times to th=
e
>> stack without having the stack consume it before the last time I
>> deliver it.
>> Of course I would like to avoid cloning it.
>
> Just do get_page() on the page having another packet in it before
> passing skb up.
>

I can see the path:
__kfree_skb -> skb_release_all -> skb_release_data -> put_page
put_page will free the page iff the _count variable reaches 0. Of cours=
e,
_count is incremented by get_page.

I will give it try.

I understand that this will work regardless the order given to
alloc_pages right ?

Thanks
