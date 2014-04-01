From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: [PATCH 3.13.y] nfqueue: Orphan frags in nfqnl_zcopy and handle errors
Date: Tue, 1 Apr 2014 09:40:42 -0400
Message-ID: <CA+5PVA6tiA_2QEz=yOBWMhwnjhqqTMnNXU439V4zNuO2eq5FWw@mail.gmail.com>
References: <20140328142914.GB25962@hansolo.jdub.homelinux.org>
	<1396223802.1241.33.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:54310 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786AbaDANkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 09:40:43 -0400
Received: by mail-ob0-f174.google.com with SMTP id wo20so11019507obc.33
        for <netdev@vger.kernel.org>; Tue, 01 Apr 2014 06:40:42 -0700 (PDT)
In-Reply-To: <1396223802.1241.33.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 30, 2014 at 7:56 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Fri, 2014-03-28 at 10:29 -0400, Josh Boyer wrote:
>> Backport of upstream commit 36d5fe6a0007 to 3.13.y
>>
>> nfqnl_zcopy can copy elements of the frags array between skbs, but it doesn't
>> orphan them.  Also, it doesn't handle errors, so this patch takes care of that
>> as well, and modify the caller accordingly.  skb_tx_error() is also added to
>> the callers so they will signal the failed delivery towards the creator of the
>> skb.
>>
>> Fixes CVE-2014-2568.
>>
>> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>
> [...]
>
> FWIW, I applied the same change to Debian's 3.13.7-1, except for leaving
> 'from' as pointer-to-const.

Thanks for the confirmation, Ben.  I noticed Dave already has the
original patch in his stable bundle on patchwork, so perhaps he's
going to do his own backport.  (Though he has v4 in the bundle and v5
is what went in-tree.)  I figured I would just send mine along in case
it was helpful.

josh
