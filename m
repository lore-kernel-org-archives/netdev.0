From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH 09/26] atl1: refactor tx processing
Date: Tue, 22 Jan 2008 18:31:09 -0600
Message-ID: <20080122183109.5ab80802@osprey.hogchain.net>
References: <1199152804-3889-1-git-send-email-jacliburn@bellsouth.net>
	<1199152804-3889-10-git-send-email-jacliburn@bellsouth.net>
	<4795BE39.6000505@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754261AbYAWAbY@vger.kernel.org>
In-Reply-To: <4795BE39.6000505@garzik.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 22 Jan 2008 04:58:17 -0500
Jeff Garzik <jeff@garzik.org> wrote:

> jacliburn@bellsouth.net wrote:
> > From: Jay Cliburn <jacliburn@bellsouth.net>
> > 
> > Refactor tx processing to use a less convoluted tx packet
> > descriptor and to conform generally with the vendor's current
> > version 1.2.40.2.
> > 
> > Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> > ---
> >  drivers/net/atlx/atl1.c |  265
> > +++++++++++++++++++++++++----------------------
> > drivers/net/atlx/atl1.h |  201 +++++++++++++++++++-----------------
> > 2 files changed, 246 insertions(+), 220 deletions(-)
> 
> for such a huge patch, this description is very tiny.  [describe]
> what is refactored, and why.

Okay, I'll go back and rework the offending descriptions for this and
the other patches in this set.

> what does "less convoluted" mean?

I should have written "simpler," I suppose.

Before:
=======
struct tso_param {
	u32 tsopu;      /* tso_param upper word */
	u32 tsopl;      /* tso_param lower word */
};

struct csum_param {
	u32 csumpu;     /* csum_param upper word */
	u32 csumpl;     /* csum_param lower word */
};

union tpd_descr {
	u64 data;
	struct csum_param csum;
	struct tso_param tso;
};

struct tx_packet_desc {
	__le64 buffer_addr;
	union tpd_descr desc;
};


After:
======
struct tx_packet_desc {
        __le64 buffer_addr;
        __le32 word2;
        __le32 word3;
};
