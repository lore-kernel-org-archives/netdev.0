From: "Vick, Matthew" <matthew.vick@intel.com>
Subject: Re: [PATCH] igb: fix PHC stopping on max freq
Date: Tue, 19 Mar 2013 21:17:25 +0000
Message-ID: <CD6E221E.1657D%matthew.vick@intel.com>
References: <f254bc583cbe1f623bd6ebb4ff375e440696d8b2.1363703896.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Stefan Assmann <sassmann@redhat.com>
To: Jiri Benc <jbenc@redhat.com>, "netdev@vger.kernel.org"
	<netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <f254bc583cbe1f623bd6ebb4ff375e440696d8b2.1363703896.git.jbenc@redhat.com>
Content-Language: en-US
Content-ID: <1FB41EFDCD2D7643BD2E822460EF9C9D@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 3/19/13 7:42 AM, "Jiri Benc" <jbenc@redhat.com> wrote:

>For 82576 MAC type, max_adj is reported as 1000000000 ppb. However, if
>this value is passed to igb_ptp_adjfreq_82576, incvalue overflows out of
>INCVALUE_82576_MASK, resulting in setting of zero TIMINCA.incvalue,
>stopping
>the PHC (instead of going at twice the nominal speed).
>
>Fix the advertised max_adj value to the largest value hardware can handle.
>As there is no min_adj value available (-max_adj is used instead), this
>will
>also prevent stopping the clock intentionally. It's probably not a big
>deal,
>other igb MAC types don't support stopping the clock, either.
>
>Signed-off-by: Jiri Benc <jbenc@redhat.com>
>---
> drivers/net/ethernet/intel/igb/igb_ptp.c |    2 +-
> 1 files changed, 1 insertions(+), 1 deletions(-)
>
>diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c
>b/drivers/net/ethernet/intel/igb/igb_ptp.c
>index 0987822..0a23750 100644
>--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
>+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
>@@ -740,7 +740,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
> 	case e1000_82576:
> 		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
> 		adapter->ptp_caps.owner = THIS_MODULE;
>-		adapter->ptp_caps.max_adj = 1000000000;
>+		adapter->ptp_caps.max_adj = 999999881;
> 		adapter->ptp_caps.n_ext_ts = 0;
> 		adapter->ptp_caps.pps = 0;
> 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82576;
>-- 
>1.7.6.5

Good catch on this, Jiri! I know the math works out the same, but I'd
prefer it if you changed the max_adj value to 999999999, since that is
technically what we can accept before we have any issues. If you re-submit
with this change, I'll add my ACK and we can run it through our internal
testing. Thanks!

Matthew

Matthew Vick
Linux Development
Networking Division
Intel Corporation


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_d2d_mar
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
