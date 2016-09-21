From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 net-next 13/16] tcp: allow congestion control to
 expand send buffer differently
Date: Wed, 21 Sep 2016 09:25:47 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0105B1D@AcuExch.aculab.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
        <1474342763-16715-14-git-send-email-ncardwell@google.com>
 <20160920104801.67082004@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Van Jacobson <vanj@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>,
        Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:56221 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932283AbcIUJ2Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 05:28:25 -0400
In-Reply-To: <20160920104801.67082004@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger
> Sent: 20 September 2016 18:48
...
> > -	sndmem = 2 * nr_segs * per_mss;
> > +	sndmem = ca_ops->sndbuf_expand ? ca_ops->sndbuf_expand(sk) : 2;
> 
> You could avoid the conditional (if it mattered) by inheriting a default value
> that would mean changing all existing congestion control modules.
> So doing it this way makes life easier.

The indirect call is probably worse than the conditional.

	David
