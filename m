From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/3][NET_BATCH] net core use batching
Date: Mon, 08 Oct 2007 09:17:24 -0400
Message-ID: <1191849444.4352.29.camel@localhost>
References: <OF9A1CB7CB.5E22F8B7-ON6525736E.001B7EF8-6525736E.001BC875@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	Patrick McHardy <kaber@trash.net>, kumarkr@linux.ibm.com,
	mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com, randy.dunlap@oracle.com,
	rdreier@cisco.com, rick.jones2@hp.com, Robert.Olsson@data.slu.se,
	shemminger@linux-foundation.org, sri@us.ibm.com, tgraf@suug.ch,
	xma@us.ibm.com
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:61135 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753574AbXJHNRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 09:17:39 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1316474wxd
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2007 06:17:38 -0700 (PDT)
In-Reply-To: <OF9A1CB7CB.5E22F8B7-ON6525736E.001B7EF8-6525736E.001BC875@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-10 at 10:33 +0530, Krishna Kumar2 wrote:

> > As a side note: Any batching driver should _never_ have to requeue; if
> > it does it is buggy. And the non-batching ones if they ever requeue will
> > be a single packet, so not much reordering.
> 
> On the contrary, batching LLTX drivers (if that is not ruled out) will very
> often requeue resulting in heavy reordering. Fix looks good though.

Two things: 
one, LLTX is deprecated (I think i saw a patch which says no more new
drivers should do LLTX) and i plan if nobody else does to kill 
LLTX in e1000 RSN. So for that reason i removed all code that existed to
support LLTX.
two, there should _never_ be any requeueing even if LLTX in the previous
patches when i supported them; if there is, it is a bug. This is because
we dont send more than what the driver asked for via xmit_win. So if it
asked for more than it can handle, that is a bug. If its available space
changes while we are sending to it, that too is a bug.

cheers,
jamal

