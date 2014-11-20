From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Wed, 19 Nov 2014 22:41:25 -0800
Message-ID: <1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
	 <1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <546C4022.5010509@oracle.com>
	 <CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wengang <wen.gang.wang@oracle.com>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:44373 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbaKTGl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 01:41:27 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so2174543ier.18
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 22:41:27 -0800 (PST)
In-Reply-To: <CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-11-19 at 14:26 -0800, Cong Wang wrote:
> On Tue, Nov 18, 2014 at 11:00 PM, Wengang <wen.gang.wang@oracle.com> wrote:
> >
> > Yes, that's true. So the simplest way is move ipoib_header_ops to vmlinux.
> >
> 
> That is not an option. Perhaps you need RCU to protect the dev->header_ops
> pointer.

This _is_ a reasonable option, especially for stable kernels

ipoib_hard_header() is 100 bytes or less. Adding infrastructure all over
the kernel to be able to use RCU or module refcounting will cost much
more.

Tell me why it is ok for eth_header_ops() being static (while its _much_
bigger), and not for ipoib_header_ops. This looks pretty arbitrary to
me.
