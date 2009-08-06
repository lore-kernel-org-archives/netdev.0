From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: Serialize access to PCI config space
Date: Thu, 6 Aug 2009 08:34:36 -0700
Message-ID: <20090806083436.2879bf7b@nehalam>
References: <4A7ABA23.6060201@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rene Mayrhofer <rene@mayrhofer.eu.org>,
	Richard Leitner <leitner@esys.at>
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35640 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755890AbZHFPel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 11:34:41 -0400
In-Reply-To: <4A7ABA23.6060201@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Aug 2009 20:10:27 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> PCI config space may be shared across two device instances,
>  or accessed from an interrupt
>  , so serialize access so
>  read-update-write operations do not interfere with each other.
> 
> Only tested on a single port card, as my sky2 doesn't have dual ports.
> 
> Signed-off-by: Mike McCormack <mikem@ring3k.org>

No, more locks is not better design.  Better to just use existing
RTNL mutex consistently.
