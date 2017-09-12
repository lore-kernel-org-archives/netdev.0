From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] tipc: Use bsearch library function
Date: Tue, 12 Sep 2017 09:24:17 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00735D7@AcuExch.aculab.com>
References: <20170909031819.13622-1-thomas@m3y3r.de>
 <20170911.143025.555018840006192902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "jon.maloy@ericsson.com" <jon.maloy@ericsson.com>,
        "ying.xue@windriver.com" <ying.xue@windriver.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
        "thomas@m3y3r.de" <thomas@m3y3r.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:63879 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751410AbdILJY2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 05:24:28 -0400
In-Reply-To: <20170911.143025.555018840006192902.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 11 September 2017 22:30
> From: Thomas Meyer <thomas@m3y3r.de>
> Date: Sat,  9 Sep 2017 05:18:19 +0200
> 
> > @@ -168,6 +169,18 @@ static struct name_seq *tipc_nameseq_create(u32 type, struct hlist_head
> *seq_hea
> >  	return nseq;
> >  }
> >
> > +static int nameseq_find_subseq_cmp(const void *key, const void *elt)
> > +{
> > +	u32 instance = *(u32 *)key;
> > +	struct sub_seq *sseq = (struct sub_seq *)elt;
> 
> Please order local variables from longest to shortest (ie. reverse
> christmas tree).

You probably just need to remove the unnecessary cast of 'void *'.
Although adding the 'const' qualifier will make it wrong again.

You probably ought to make the 'key' a structure - even if it only
contains a single u32.
Casting pointers to numeric types is often wrong.

	David
