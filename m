From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 10/10] chelesio: transmit locking (plus bug fix).
Date: Mon, 4 Dec 2006 09:58:28 -0800
Message-ID: <20061204095828.0e50f359@freekitty>
References: <20061202003612.573260000@osdl.org>
	<20061202003707.873200000@osdl.org>
	<5cac192f0612030245j434db528sd7bc755408827cf7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:45845 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936085AbWLDR6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 12:58:40 -0500
To: "Eric Lemoine" <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0612030245j434db528sd7bc755408827cf7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 3 Dec 2006 11:45:09 +0100
"Eric Lemoine" <eric.lemoine@gmail.com> wrote:

> Stephen,
> 
> On 12/2/06, Stephen Hemminger <shemminger@osdl.org> wrote:
> > If transmit lock is contended on, then push return code back
> > and retry at higher level.
> 
> Looking at qdisc_restart, it seems to me that the NETDEV_TX_LOCKED
> return code must only be used if the device features LLTX. With your
> patch, if q->lock is already grabbed, qdisc_restart is going to
> requeue skb without going through the collision section of
> qdisc_restart.
>
The Chelsio driver already sets LLTX (see drivers/net/chelsio/cxgb2.c)
