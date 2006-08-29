From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 15/26] e100: reduce time under spinlock
Date: Tue, 29 Aug 2006 16:55:20 -0400
Message-ID: <44F4A9B8.9050407@pobox.com>
References: <20060829164153.6872.1713.stgit@gitlost.site> <20060829164448.6872.18583.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:63372 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965350AbWH2UzX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 16:55:23 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060829164448.6872.18583.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> We're waiting for a write flush to finish before unlocking, which
> is not needed. Release the spinlock after the write command.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

This undoes the following change:


commit ad8c48ad3bbef078616ed4d2652d362dfd962f09
Author: Catalin(ux aka Dino) BOIE <util@deuroconsult.ro>
Date:   Sat Mar 4 12:18:59 2006 -0500

     Fix io ordering problems in e100

     Checking e100.c code against Documentation/io_ordering.txt I found the
     following problem:

     spin_lock_irq...
     write
     spin-unlock
     e100_write_flush

     The attached patch fix the code like this:

     spin_lock_irq...
     write
     e100_write_flush
     spin-unlock

     Signed-off-by: Catalin BOIE <catab@umbrella.ro>
     Signed-off-by: Jeff Garzik <jeff@garzik.org>

