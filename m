From: Xi Wang <xi.wang@gmail.com>
Subject: Re: [PATCH] ipv4: avoid undefined behavior in do_ip_setsockopt()
Date: Sun, 11 Nov 2012 17:18:55 -0500
Message-ID: <50A0244F.1070302@gmail.com>
References: <1352668801-14373-1-git-send-email-xi.wang@gmail.com> <20121111.170247.780516266044882867.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:50015 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752303Ab2KKWS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2012 17:18:58 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so5526488vcb.19
        for <netdev@vger.kernel.org>; Sun, 11 Nov 2012 14:18:57 -0800 (PST)
In-Reply-To: <20121111.170247.780516266044882867.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/11/12 5:02 PM, David Miller wrote:
> 
> This code is a fast bit test on purpose.  You're making the
> code slower.

No, it's the opposite.  All modern compilers optimize switch cases
into a fast bit test.  The original "smarter" code, however, hinders
the compiler determining the mask for a fast bit test.  With this
patch, GCC is able to compute a better mask.  You can check the
assembly.

- xi
