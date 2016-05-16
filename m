From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] e1000e: prevent division by zero if
	TIMINCA is zero
Date: Mon, 16 May 2016 22:31:53 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81EFDBA5@ORSMSX101.amr.corp.intel.com>
References: <1462563711-30350-1-git-send-email-dvlasenk@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Denys Vlasenko <dvlasenk@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41488 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879AbcEPWby convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 18:31:54 -0400
In-Reply-To: <1462563711-30350-1-git-send-email-dvlasenk@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Denys Vlasenko
> Sent: Friday, May 6, 2016 12:42 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>
> Cc: intel-wired-lan@lists.osuosl.org; Denys Vlasenko
> <dvlasenk@redhat.com>; LKML <linux-kernel@vger.kernel.org>;
> netdev@vger.kernel.org
> Subject: [Intel-wired-lan] [PATCH] e1000e: prevent division by zero if
> TIMINCA is zero
> 
> Users report that under VMWare, er32(TIMINCA) returns zero.
> This causes division by zero at init time as follows:
> 
>  ==>            incvalue = er32(TIMINCA) & E1000_TIMINCA_INCVALUE_MASK;
>                 for (i = 0; i < E1000_MAX_82574_SYSTIM_REREADS; i++) {
>                         /* latch SYSTIMH on read of SYSTIML */
>                         systim_next = (cycle_t)er32(SYSTIML);
>                         systim_next |= (cycle_t)er32(SYSTIMH) << 32;
> 
>                         time_delta = systim_next - systim;
>                         temp = time_delta;
>  ====>                  rem = do_div(temp, incvalue);
> 
> This change makes kernel survive this, and users report that
> NIC does work after this change.
> 
> Since on real hardware incvalue is never zero, this should not affect
> real hardware use case.
> 
> Signed-off-by: Denys Vlasenko <dvlasenk@redhat.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: "Ruinskiy, Dima" <dima.ruinskiy@intel.com>
> CC: intel-wired-lan@lists.osuosl.org
> CC: netdev@vger.kernel.org
> CC: LKML <linux-kernel@vger.kernel.org>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)

As Mark Rustad pointed out I recall this was earlier rejected as something that is a VMWare error and it should be fixed there so that existing VMs will start working without installing a new driver.  Having said that, it does not seem to be causing any harm in my testing, so...

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
