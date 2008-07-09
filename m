From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] tun: Persistent devices can get stuck in xoff state
Date: Wed, 9 Jul 2008 17:59:39 +0200
Message-ID: <200807091759.39171.borntraeger@de.ibm.com>
References: <1215584648-13444-1-git-send-email-maxk@qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Max Krasnyansky <maxk@qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:3138 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754616AbYGIQAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 12:00:01 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m69Fxg1p559280
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 15:59:42 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m69Fxg1g2474178
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 16:59:42 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m69FxflL028544
	for <netdev@vger.kernel.org>; Wed, 9 Jul 2008 16:59:41 +0100
In-Reply-To: <1215584648-13444-1-git-send-email-maxk@qualcomm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 9. Juli 2008 schrieb Max Krasnyansky:
> The scenario goes like this. App stops reading from tun/tap.
> TX queue gets full and driver does netif_stop_queue().
> App closes fd and TX queue gets flushed as part of the cleanup.
> Next time the app opens tun/tap and starts reading from it but
> the xoff state is not cleared. We're stuck.
> Normally xoff state is cleared when netdev is brought up. But
> in the case of persistent devices this happens only during
> initial setup.

I was able to reproduce the problem. The patch seems to fix it.

Tested-by: Christian Borntraeger <borntraeger@de.ibm.com>

