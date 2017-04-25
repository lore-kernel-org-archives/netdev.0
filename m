From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH net] macsec: avoid heap overflow in skb_to_sgvec on receive
Date: Tue, 25 Apr 2017 17:39:09 +0200
Message-ID: <CAHmME9rxdTEe1-5ApgUhdkqiJztSgJb0QuhV2uSemobeXm_oNg@mail.gmail.com>
References: <f50ef5b9e525d83938f5e419557abb0307ee023b.1493133423.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:53657 "EHLO frisell.zx2c4.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970510AbdDYPjN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 11:39:13 -0400
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTP id 78171991
        for <netdev@vger.kernel.org>;
        Tue, 25 Apr 2017 15:30:31 +0000 (UTC)
Received: by frisell.zx2c4.com (ZX2C4 Mail Server) with ESMTPSA id 040d473d (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128:NO)
        for <netdev@vger.kernel.org>;
        Tue, 25 Apr 2017 15:30:30 +0000 (UTC)
Received: by mail-oi0-f41.google.com with SMTP id w12so64155884oiw.3
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 08:39:11 -0700 (PDT)
In-Reply-To: <f50ef5b9e525d83938f5e419557abb0307ee023b.1493133423.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sabrina,

I think I may have beaten you to the punch here by a few minutes. :)

The difference between our two versions is that you don't re-add the
FRAGLIST attribute, whereas my patch does, and then it does the
dynamic allocation. I suspect this might be a bit more robust. It also
ensures that skb_cow_data is called on both paths. So perhaps let's
roll with mine?

Jason
