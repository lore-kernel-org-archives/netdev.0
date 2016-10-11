From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH] IB/ipoib: move back the IB LL address into the hard
 header
Date: Tue, 11 Oct 2016 20:10:07 +0200
Message-ID: <1476209407.448.9.camel@redhat.com>
References: <1dbd83dfe7f435eecc5bc460e901b47758280f30.1476206016.git.pabeni@redhat.com>
         <20161011173216.GA16892@obsidianresearch.com>
         <22f61258-9bcf-0adc-f23f-79a4f1d50c6a@redhat.com>
         <20161011180119.GB17319@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        netdev@vger.kernel.org
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45972 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753244AbcJKSKM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 14:10:12 -0400
In-Reply-To: <20161011180119.GB17319@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-11 at 12:01 -0600, Jason Gunthorpe wrote:
> > AFAICS the max mtu is already underlying h/w dependent, how does such
> > differences are currently coped by ? (I'm sorry I lack some/a lot of IB
> > back-ground)
> 
> It isn't h/w dependent. In CM mode the MTU is 65520 because that is
> what is hard coded into the ipoib driver. We tell everyone to use that
> number. Eg see RH's docs on the subject:
> 
> https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Networking_Guide/sec-Configuring_IPoIB.html
> 
> AFAIK, today everyone just wires that number into their scripts, so we
> have to mass change everything to the smaller number. That sounds
> really hard, IMHO if there is any way to avoid it we should, even if
> it is a little costly.

Thank you for the details!

The first s/g fragment (the head buffer) is not allocated with the page
allocator, so perhaps there is some not too difficult/costly way out of
this.
