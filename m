From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] e1000: Don't enable polling in open()
	(was: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1)
Date: Mon, 21 May 2007 18:16:35 -0400
Message-ID: <20070521221635.GA16888@redhat.com>
References: <20070521215134.14885.84952.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jeff@garzik.org,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	greg@suse.de, stable@vger.kernel.org
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20070521215134.14885.84952.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, May 21, 2007 at 02:51:35PM -0700, Auke Kok wrote:
 > Herbert Xu wrote:
 > "netif_poll_enable can only be called if you've previously called
 > netif_poll_disable.  Otherwise a poll might already be in action
 > and you may get a crash like this."
 > 
 > Removing the call to netif_poll_enable in e1000_open should fix this issue,
 > the only other call to netif_poll_enable is in e1000_up() which is only
 > reached after a device reset or resume.
 > 
 > Bugzilla: http://bugzilla.kernel.org/show_bug.cgi?id=8455
 > https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240339

This probably doesn't solve the latter bug.
The code you reference isn't there in the kernel tested in that bug
(2.6.21)   In 2.6.21, netif_poll_enable is only called from
e1000_up(), not e1000_open()

	Dave

-- 
http://www.codemonkey.org.uk

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
