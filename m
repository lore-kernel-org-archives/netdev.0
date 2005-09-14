From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH] New PowerPC 4xx on-chip ethernet controller driver
Date: Wed, 14 Sep 2005 10:08:33 -0700
Message-ID: <20050914170833.GB21263@gate.ebshome.net>
References: <20050831045847.GA17017@gate.ebshome.net>
	<20050831050048.GB17017@gate.ebshome.net>
	<43281B7D.5000106@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <43281B7D.5000106@pobox.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2005 at 08:45:49AM -0400, Jeff Garzik wrote:
> Eugene Surovegin wrote:
> >Remove old PPC4xx EMAC driver
> >
> >Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
> 
> Please post a diff, along with a description of the changes.
> 
> One huge patch to "remove emac driver" and another huge patch to "add 
> emac driver" is quite silly.

This patch replaces current PowerPC 4xx EMAC driver with
new, re-written version.

New driver uses NAPI, it solves stability problems under heavy packet 
load and low memory, corrects chip register access and fixes numerous 
small bugs I don't even remember now :).

This patch has been tested on all supported in 2.6 PPC 4xx boards.
It's been used in production for almost a year now on custom
4xx hardware. PPC32 specific parts are already upstream.

Patch was acked by the current EMAC driver maintainer (Matt Porter). I
will be maintaining this new version.

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>

--

 Kconfig                   |   72
 ibm_emac/Makefile         |   13
 ibm_emac/ibm_emac.h       |  418 +++--
 ibm_emac/ibm_emac_core.c  | 3391 ++++++++++++++++++++++++----------------------
 ibm_emac/ibm_emac_core.h  |  313 ++--
 ibm_emac/ibm_emac_debug.c |  377 ++---
 ibm_emac/ibm_emac_debug.h |   63
 ibm_emac/ibm_emac_mal.c   |  671 +++++----
 ibm_emac/ibm_emac_mal.h   |  336 +++-
 ibm_emac/ibm_emac_phy.c   |  335 ++--
 ibm_emac/ibm_emac_phy.h   |  105 -
 ibm_emac/ibm_emac_rgmii.c |  202 ++
 ibm_emac/ibm_emac_rgmii.h |   68
 ibm_emac/ibm_emac_tah.c   |  111 +
 ibm_emac/ibm_emac_tah.h   |   96 -
 ibm_emac/ibm_emac_zmii.c  |  256 +++
 ibm_emac/ibm_emac_zmii.h  |  114 -
 17 files changed, 4119 insertions(+), 2822 deletions(-)

Patch is quite big (~234K) because there is virtualy 0% of common code 
between old and new version.

It can be found at http://kernel.ebshome.net/emac/4xx_napi_emac.diff
