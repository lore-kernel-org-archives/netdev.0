From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] improve configopt, slightly correct acx111 radio recalib
Date: Wed, 11 Jan 2006 08:42:24 +0200
Message-ID: <200601110842.24245.vda@ilport.com.ua>
References: <20060110151104.GA28270@rhlx01.fht-esslingen.de>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: andi@lisas.de
In-Reply-To: <20060110151104.GA28270@rhlx01.fht-esslingen.de>
Content-Disposition: inline
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

On Tuesday 10 January 2006 17:11, Andreas Mohr wrote:
> Hi all,
> 
> this patch adds support for configopt parsing for ACX100 EEPROM version v5
> (please report whether ACX100 v5 now works, preferrably with logs showing
> configopt activity).
> 
> Also, we now only start another radio recalibration interval every 5 seconds
> on ACX111 instead of every second (in case of radio recalibration FAILURES,
> that is). 5 recalibration attempts every second in case of repeated failure
> is waaaaay too much, both for undistorted card operation and syslog.

-unsigned int acx_debug = L_ASSOC|L_INIT;
+unsigned int acx_debug __read_mostly = L_ASSOC|L_INIT;

I think __read_mostly is not worth the compat trouble it currently will require
(#ifdef LINUX_VERSION_CODE...).

+       }
+       else
+       {

Changing this to "} else {".

Patch applied, thanks!

BTW, currently we have

        priv->scan_probe_delay = 200;
        /* reported to break scanning: priv->scan_probe_delay = priv->cfgopt_probe_delay; */

Do I need to uncomment that?
--
vda


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
