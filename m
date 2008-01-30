From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [BUILD FAILURE] 2.6.24-git7 section type conflict at various drivers on powerpc
Date: Wed, 30 Jan 2008 18:04:17 +0100
Message-ID: <20080130170417.GA24386@uranus.ravnborg.org>
References: <47A0A3AF.5050005@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Andy Whitcroft <apw@shadowen.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762191AbYA3REi@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47A0A3AF.5050005@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 30, 2008 at 09:49:59PM +0530, Kamalesh Babulal wrote:
> Hi,
> 
> Following are the different build failure with 2.6.24-git7 kernel on the powerpc
> 
> drivers/net/typhoon.c:181: error: typhoon_card_info causes a section type conflict
> make[2]: *** [drivers/net/typhoon.o] Error 1
> 
> drivers/net/natsemi.c:259: error: natsemi_pci_info causes a section type conflict
> make[2]: *** [drivers/net/natsemi.o] Error 1
> 
> drivers/net/bnx2.c:95: error: board_info causes a section type conflict
> make[2]: *** [drivers/net/bnx2.o] Error 1
> 
> drivers/net/via-velocity.c:454: error: velocity_id_table causes a section type conflict
> make[2]: *** [drivers/net/via-velocity.o] Error 1

A quick look told me that they are all caused by const data
annotated with __devinitdata.
Try replacing all annotations of const variables
from __devinitdata to __devinitconst.

	Sam
