From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2/2]: e1000: avoid lockup durig error
	recovery
Date: Wed, 7 Nov 2007 17:15:38 -0800
Message-ID: <20071107171538.1802487c@freepuppy.rosehill>
References: <20071107211935.GH4239@austin.ibm.com>
	<20071107212404.GA15251@austin.ibm.com> <47323319.10709@intel.com>
	<20071107222446.GM4239@austin.ibm.com> <47323FFE.2060008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	NetDev <netdev@vger.kernel.org>,
	"Brandeburg,  Jesse" <jesse.brandeburg@intel.com>,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	Linas Vepstas <linas@austin.ibm.com>, wenxiong@us.ibm.com
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47323FFE.2060008@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Wed, 07 Nov 2007 14:45:18 -0800
"Kok, Auke" <auke-jan.h.kok@intel.com> wrote:

> [adding netdev, jeff G to the Cc]
> 
> Linas Vepstas wrote:
> > On Wed, Nov 07, 2007 at 01:50:17PM -0800, Kok, Auke wrote:
> >> Linas Vepstas wrote:
> >>> If a PCI bus error is encountered during device open, the
> >>> error recovery routines will attempt to close the device.
> >>> If napi has not yet been enabled, the napi disable in the
> >>> close will hang. 
> >>>
> >>> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> >>>
> >>> ----
> >>> The "elegence" of this solution is arguable: one could
> >>> say its "better" to perform this check in e1000_down().
> >>> However, doing so will disrupt a commonly used path,
> >>> whereas here, the hack is in the infrequently used
> >>> error path, and thus less intrusive. 
> >>>

Same problem might be possible in suspend/resume.
The problem with testing napi_enabled is that state can get changed
by racing irq.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
