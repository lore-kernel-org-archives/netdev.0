From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH 3/4] ptp: use is_visible method to hide unused attributes
Date: Tue, 14 Feb 2017 10:07:47 -0800
Message-ID: <20170214180747.GA4081@dtor-ws>
References: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
 <20170214035108.19622-3-dmitry.torokhov@gmail.com>
 <20170214084226.GC8048@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214084226.GC8048@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Richard,

On Tue, Feb 14, 2017 at 09:42:26AM +0100, Richard Cochran wrote:
> On Mon, Feb 13, 2017 at 07:51:07PM -0800, Dmitry Torokhov wrote:
> > Instead of creating selected attributes after the device is created (and
> > after userspace potentially seen uevent), lets use attribute group
> > is_visible() method to control which attributes are shown. This will allow
> > us to create all attributes (except "pins" group, which will be taken care
> > of later) before userspace gets notified about new ptp class device.
> 
> At first glance, this patch and the next look like nice improvements.
> I don't futz around with sysfs code very often, and so may I ask how
> or whether you tested it?

I used the hack below.

Thanks.

-- 
Dmitry

PTP Test

Signed-off-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/ptp.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ptp.c b/drivers/net/ethernet/intel/e1000e/ptp.c
index 34cc3be0df8e..3b4c0d3e4093 100644
--- a/drivers/net/ethernet/intel/e1000e/ptp.c
+++ b/drivers/net/ethernet/intel/e1000e/ptp.c
@@ -260,18 +260,27 @@ static void e1000e_systim_overflow_work(struct work_struct *work)
 			      E1000_SYSTIM_OVERFLOW_PERIOD);
 }
 
+static struct ptp_pin_desc e1000e_ptp_pin_config[1] = {
+	{
+		.name = "TestPin1",
+		.index = 0,
+		.func = PTP_PF_NONE,
+	}
+};
+
 static const struct ptp_clock_info e1000e_ptp_clock_info = {
 	.owner		= THIS_MODULE,
 	.n_alarm	= 0,
 	.n_ext_ts	= 0,
-	.n_per_out	= 0,
-	.n_pins		= 0,
+	.n_per_out	= 1,
+	.n_pins		= 1,
 	.pps		= 0,
 	.adjfreq	= e1000e_phc_adjfreq,
 	.adjtime	= e1000e_phc_adjtime,
 	.gettime64	= e1000e_phc_gettime,
 	.settime64	= e1000e_phc_settime,
 	.enable		= e1000e_phc_enable,
+	.pin_config	= e1000e_ptp_pin_config,
 };
 
 /**
