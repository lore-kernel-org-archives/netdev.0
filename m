From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Serialize access to PCI config space
Date: Mon, 10 Aug 2009 08:27:21 -0700
Message-ID: <20090810082721.74edeb1d@nehalam>
References: <4A7EB4EF.3030106@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58654 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752145AbZHJP1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 11:27:53 -0400
In-Reply-To: <4A7EB4EF.3030106@ring3k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 09 Aug 2009 20:37:19 +0900
Mike McCormack <mikem@ring3k.org> wrote:

> 
> Disable NAPI when powering up or down the phy, as sky2_err_intr
>  may also access the PCI config space.
> 

Also access to PCI config is done through shared memory, so each
access is atomic. The only issue is the stupid config write bit;
this bit really doesn't protect from anything useful.
Probably better to just always leave it TST_CFG_WRITE_ON.
