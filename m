From: Phil Sutter <phil@nwl.cc>
Subject: Re: rhashtable: how to deal with that rhashtable_lookup_insert_key
 return -EBUSY
Date: Fri, 20 Nov 2015 13:24:01 +0100
Message-ID: <20151120122401.GB16648@orbit.nwl.cc>
References: <CADvbK_drKzCbByS38==rkC8yRtQhRj6mOtKAgXeHLwOhdh6Z1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, network dev <netdev@vger.kernel.org>,
	tgraf@suug.ch, herbert@gondor.apana.org.au,
	davem <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:40236 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760081AbbKTMYE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Nov 2015 07:24:04 -0500
Content-Disposition: inline
In-Reply-To: <CADvbK_drKzCbByS38==rkC8yRtQhRj6mOtKAgXeHLwOhdh6Z1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 20, 2015 at 01:14:18PM +0800, Xin Long wrote:
> when I use rhashtable_lookup_insert_key, sometimes it will return -EBUSY.
> im not sure if there is a good way to workabout it.
> or I should just try again and again until it's inserted successfully ?
> 
> I have seen some use in kernel  by now, but it seems that no one consider
> this issue for their cases. but it indeed exists in my case.
> 
> did I use it incorrectly or something else ?

AFAIK, insert returning -EBUSY is a situation users have to be aware of
and retry the insert. I sent a patch[1] to fix this in test_rhashtable.

That patch though retried in case of -ENOMEM as well, which was
considered wrong to do and therefore it wasn't accepted. But in my test
runs, -ENOMEM happened quite frequently and it also wasn't a permanent
error. For details, see the following discussion[2].

Herbert, did you manage to reproduce the problem meanwhile? If so, was
there any progress on fixing rhashtable? Otherwise, I could respin my
patch from [1] to cover only -EBUSY case by default and add a parameter
to make non-permanent -ENOMEM visible.

Cheers, Phil

[1]: https://lkml.org/lkml/2015/8/28/197
[2]: https://lkml.org/lkml/2015/8/28/281
> 
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
