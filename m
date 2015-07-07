From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH] vmxnet3: prevent receive getting out of sequence on napi
 poll
Date: Tue, 7 Jul 2015 14:10:50 -0400
Message-ID: <20150707181049.GC588@gospo.home.greyhouse.net>
References: <1436292138-18190-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Shreyas Bhatewara <sbhatewara@vmware.com>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35073 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407AbbGGSKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 14:10:53 -0400
Received: by qkbp125 with SMTP id p125so145739240qkb.2
        for <netdev@vger.kernel.org>; Tue, 07 Jul 2015 11:10:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1436292138-18190-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, 2015 at 02:02:18PM -0400, Neil Horman wrote:
> vmxnet3's current napi path is built to count every rx descriptor we recieve,
> and use that as a count of the napi budget.  That means its possible to return
> from a napi poll halfway through recieving a fragmented packet accross multiple
> dma descriptors.  If that happens, the next napi poll will start with the
> descriptor ring in an improper state (e.g. the first descriptor we look at may
> have the end-of-packet bit set), which will cause a BUG halt in the driver.
> 
> Fix the issue by only counting whole received packets in the napi poll and
> returning that value, rather than the descriptor count.
> 
> Tested by the reporter and myself, successfully
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Shreyas Bhatewara <sbhatewara@vmware.com>
> CC: "David S. Miller" <davem@davemloft.net>

Looks good.  I'm now curious how widespread something like this might be
for drivers that use a similar EOP marker....

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
