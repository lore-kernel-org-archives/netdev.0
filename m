From: Wei Liu <liuw@liuw.name>
Subject: Re: [Xen-devel] [PATCH 5/6] xen-netback: coalesce slots before copying
Date: Mon, 25 Mar 2013 17:06:01 +0000
Message-ID: <CAOsiSVXcKc583rEb9hXhtuhpTtrQ+ib_pgxaX9h77v98BWfgKg@mail.gmail.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-6-git-send-email-wei.liu2@citrix.com> <5150699C.6080209@citrix.com>
 <CAOsiSVUNO0FQkfJWjv9bcoMgKNnHu4XYciz61hG3YNFzZNxK3w@mail.gmail.com>
 <51507C9B.3080109@citrix.com> <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:56158 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932272Ab3CYRGe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:06:34 -0400
Received: by mail-we0-f176.google.com with SMTP id s43so997693wey.21
        for <netdev@vger.kernel.org>; Mon, 25 Mar 2013 10:06:33 -0700 (PDT)
In-Reply-To: <CAOsiSVV8gtKqFxyAr3XN9YF78WjtFqzvx5mnA1dKTrS_4qzXBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 25, 2013 at 4:58 PM, Wei Liu <liuw@liuw.name> wrote:
>
> So it is a bit tricky here. Let me clarify this, the head field is
> used to indicate the start of a new tx requests queue and the end of
> previous queue.
>
> Imagine a sequence of head fileds(I = INVALID_PENDING_RING_IDX below),
> the number is the starting index of pending ring.
>
>   .... 0 I I I 5 I I ...
>
> consume all tx_info but not setting I to 0 (or any number other then
> I) makes the sequence remains the same as before. The in subsequent
> call to process next SKB, which has 3 extra slots, which makes the

Sorry, should be "4 extra slots"

sequence looks like

  .... 8 | | | | | | ...

but in fact the correct sequence should be

  .... 8 | | | | 0 0 ...


Wei.
