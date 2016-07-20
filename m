From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [Intel-wired-lan] [PATCH net] e1000e: fix PTP on e1000_pch_lpt
 variants
Date: Wed, 20 Jul 2016 13:05:33 -0400
Message-ID: <20160720170533.GE37138@redhat.com>
References: <1468959902-25071-1-git-send-email-jarod@redhat.com>
 <B2E38BF8-6BB1-4904-B79B-B94B9C360F15@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Rustad, Mark D" <mark.d.rustad@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <B2E38BF8-6BB1-4904-B79B-B94B9C360F15@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 19, 2016 at 08:49:03PM +0000, Rustad, Mark D wrote:
> Jarod Wilson <jarod@redhat.com> wrote:
> 
> >I've got reports that the Intel I-218V NIC in Intel NUC5i5RYH systems used
> >as a PTP slave experiences random ~10 hour clock jumps, which are resolved
> >if the same workaround for the 82574 and 82583 is employed. Switching from
> >an if to a select, because the list of NIC types could well grow further
> >and we'd already have to wrap the conditionals.
> >
> >CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >CC: intel-wired-lan@lists.osuosl.org
> >CC: netdev@vger.kernel.org
> >Signed-off-by: Jarod Wilson <jarod@redhat.com>
> >---
> > drivers/net/ethernet/intel/e1000e/netdev.c | 8 +++++++-
> > 1 file changed, 7 insertions(+), 1 deletion(-)
> >
> >diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> >b/drivers/net/ethernet/intel/e1000e/netdev.c
> >index 2b2e2f8..866fea0 100644
> >--- a/drivers/net/ethernet/intel/e1000e/netdev.c
> >+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> >@@ -4335,7 +4335,10 @@ static cycle_t
> >e1000e_cyclecounter_read(const struct cyclecounter *cc)
> > 	systim = (cycle_t)systimel;
> > 	systim |= (cycle_t)systimeh << 32;
> >
> >-	if ((hw->mac.type == e1000_82574) || (hw->mac.type == e1000_82583)) {
> >+	switch (hw->mac.type) {
> >+	case e1000_82574:
> >+	case e1000_82583:
> >+	case e1000_pch_lpt:
> > 		u64 time_delta, rem, temp;
> > 		u32 incvalue;
> > 		int i;
> 
> I don't think that it is acceptable to declare local variables
> inside a switch statement quite like this. At a minimum, a new block
> needs to be opened to allow the declarations.

Gah, sorry, I think testing was done with an if, made a late change to a
switch without doing sufficient re-testing. I'll fix that up and re-test.

-- 
Jarod Wilson
jarod@redhat.com
