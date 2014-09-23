From: Chuck Ebbert <cebbert.lkml@gmail.com>
Subject: Re: LTP recv/recvmsg tests failing on 3.17
Date: Tue, 23 Sep 2014 10:39:33 -0500
Message-ID: <20140923103933.1b5fb88b@as>
References: <20140923091108.2788de76@as>
	<CA+FuTScNSGYxWtB-D_iL_7TQO=z4r5_29-W8d=VRwh1M6Ym_UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:52049 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754994AbaIWPjk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 11:39:40 -0400
Received: by mail-oa0-f44.google.com with SMTP id eb12so5161587oac.17
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2014 08:39:38 -0700 (PDT)
In-Reply-To: <CA+FuTScNSGYxWtB-D_iL_7TQO=z4r5_29-W8d=VRwh1M6Ym_UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2014 10:57:41 -0400
Willem de Bruijn <willemb@google.com> wrote:

> I think applications simply cannot assume a consistent
> return value when passing unsupported combinations
> of flags. This is undefined behavior.

Yeah, I think LTP is wrong here. There is no explicit test for invalid
combinations of flags and it was assuming there was.

But I was also wondering why we return EAGAIN here for no data waiting,
when we return EINVAL for the same case with a different type of data.
There's no spec and it's not documented, so I guess the answer is "it's
always been that way."
