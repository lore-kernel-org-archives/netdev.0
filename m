From: Alan Modra <amodra@gmail.com>
Subject: Re: [PATCH net-next] af_unix: fix a fatal race with bit fields
Date: Fri, 3 May 2013 11:01:36 +0930
Message-ID: <20130503013136.GN5221@bubble.grove.modra.org>
References: <1367370761.11020.22.camel@edumazet-glaptop>
 <20130501115103.58e40f37@kryten>
 <1367375060.11020.24.camel@edumazet-glaptop>
 <20130501035425.GD5221@bubble.grove.modra.org>
 <1367384672.11020.34.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anton Blanchard <anton@samba.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linuxppc-dev@lists.ozlabs.org,
	Paul Mackerras <paulus@samba.org>,
	Ambrose Feinstein <ambrose@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36254 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505Ab3ECBbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 21:31:45 -0400
Received: by mail-pa0-f51.google.com with SMTP id ld10so646003pab.24
        for <netdev@vger.kernel.org>; Thu, 02 May 2013 18:31:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1367384672.11020.34.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 30, 2013 at 10:04:32PM -0700, Eric Dumazet wrote:
> These kind of errors are pretty hard to find, its a pity to spend time
> on them.

Well, yes.  From the first comment in gcc PR52080.  "For the following
testcase we generate a 8 byte RMW cycle on IA64 which causes locking
problems in the linux kernel btrfs filesystem."

Did someone fix btrfs, but not check other kernel locks?  Having now
hit the same problem again, have you checked that other kernel locks
don't have adjacent bit fields in the same 64-bit word?  And comment
the struct to ensure someone doesn't optimize those unsigned chars
back to bit fields.

-- 
Alan Modra
Australia Development Lab, IBM
