From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 1/3] virtio_net: pass well-formed sgs to virtqueue_add_*()
Date: Tue, 2 Sep 2014 21:54:11 -0700
Message-ID: <CALCETrUv4_p2drPJBbs901+Kq-86rOSUzQu1DrkvJyCLvmz9nQ@mail.gmail.com>
References: <1409718556-3041-1-git-send-email-rusty@rustcorp.com.au> <1409718556-3041-2-git-send-email-rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Linux Virtualization <virtualization@lists.linux-foundation.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:52016 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbaICEye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 00:54:34 -0400
Received: by mail-lb0-f175.google.com with SMTP id u10so8922688lbd.34
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 21:54:32 -0700 (PDT)
In-Reply-To: <1409718556-3041-2-git-send-email-rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 2, 2014 at 9:29 PM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> This is the only driver which doesn't hand virtqueue_add_inbuf and
> virtqueue_add_outbuf a well-formed, well-terminated sg.  Fix it,
> so we can make virtio_add_* simpler.

OK, I get it now: you're reinitializing the table every time, clearing
old end marks.  There's room to microoptimize this, but it's probably
not worth it.

IOW, looks good to me.

--Andy
