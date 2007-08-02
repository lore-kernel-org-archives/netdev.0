From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [REGRESSION] tg3 dead after s2ram
Date: Thu, 02 Aug 2007 16:38:00 -0700
Message-ID: <1186097880.18322.73.camel@dell>
References: <200708021115.10812.joachim.deguara@amd.com>
 <20070802.022317.66176729.davem@davemloft.net>
 <1186081829.18322.20.camel@dell>
 <20070802.150636.77057800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: joachim.deguara@amd.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	"netdev" <netdev@vger.kernel.org>, linux-acpi@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2164 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754983AbXHBWny (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 18:43:54 -0400
In-Reply-To: <20070802.150636.77057800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-08-02 at 15:06 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu, 02 Aug 2007 12:10:29 -0700
>
> > Alternatively, we can also fix it by calling pci_enable_device() again
> > in tg3_open().  But I think it is better to just always save and restore
> > in suspend/resume.  bnx2.c will also require the same fix.
> 
> We could do it that way.  But don't you think it's more reliable to
> save and restore around the event we know will be what clobbers the
> PCI config space on us? :-)
> 

Yes for sure when netif state is running and we were already doing that.

> Other things might happen between ->resume() and ->open() that could
> modify PCI config space, and we could overwrite such changes if we do
> the PCI restore in ->open().

I suggested calling pci_enable_device() in ->open(), not calling
pci_restore_state() in ->open().  I ultimately decided against it
because some devices do not enable memory as a workaround and it would
be messy to deal with it again in tg3_open().

I definitely agree that calling PCI restore in ->open() is a bad idea.
We used to save PCI state in ->probe() once and restore PCI state after
every chip reset.  This sequence caused many subtle problems.

