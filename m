From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Thu, 28 Oct 2010 12:32:35 -0700
Message-ID: <1288294355.11251.20.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
	 <1288240804.14342.1.camel@localhost.localdomain>
	 <20101028052021.GD5599@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:53697 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759407Ab0J1Tcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 15:32:39 -0400
In-Reply-To: <20101028052021.GD5599@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-28 at 07:20 +0200, Michael S. Tsirkin wrote:
> My concern is this can delay signalling for unlimited time.
> Could you pls test this with guests that do not have
> 2b5bbe3b8bee8b38bdc27dd9c0270829b6eb7eeb
> b0c39dbdc204006ef3558a66716ff09797619778
> that is 2.6.31 and older? 

The patch only induces delay signaling unlimited time when there is no
TX packet to transmit. I thought TX signaling only noticing guest to
release the used buffers, anything else beside this?

I tested rhel5u5 guest (2.6.18 kernel), it works fine. I checked the two
commits log, I don't think this patch could cause any issue w/o these
two patches.

Also I found a big TX regression for old guest and new guest. For old
guest, I am able to get almost 11Gb/s for 2K message size, but for the
new guest kernel, I can only get 3.5 Gb/s with the patch and same host.
I will dig it why.

thanks
Shirley

