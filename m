From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Prism54 wpa update
Date: Tue, 29 Jun 2004 16:22:10 -0400
Sender: prism54-devel-bounces@prism54.org
Message-ID: <20040629202210.GK23191@havoc.gtf.org>
References: <20040629192101.GB14482@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <prism54-devel-bounces@prism54.org>
To: Netdev <netdev@oss.sgi.com>, prism54-devel@prism54.org
Content-Disposition: inline
In-Reply-To: <20040629192101.GB14482@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2004 at 03:21:01PM -0400, Luis R. Rodriguez wrote:
> 
> I'll keep my latest wpa work/patch at the following URL:
> 
> http://prism54.org/~mcgrof/prism54-wpa.diff
> 
> I've nuked module params and am relying on private ioctls now since,
> 
> * we already have a [s|g]et_wpa priv iotcl, and
> * in preperation for the WPA patch for Wireless Extensions.
> 
> I'll work on wpa ie scans tonight and try to fix mgt for
> handling traps in extended mode. This is not related to wpa, but
> I also made the firmware load at probe time. I turned the radio
> off at probe after firmware load time too since the device is
> not technically up yet.

Patch seems sane, though I vaguely recall xchg() not being atomic on all
platforms (such as i386?).  Maybe I'm wrong, an expert should speak up :)

I also worry that the following is a race, but I have not traced the
code to verify or discount my guess:

+       u32 mlme, authen, dot1x, filter, wep;
+
+
+       if (islpci_get_state(priv) < PRV_STATE_INIT)
+               return 0;
 
        down_write(&priv->mib_sem);
