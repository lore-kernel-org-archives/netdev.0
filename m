From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/4] Net device error logging, revised
Date: Tue, 26 Aug 2003 11:32:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030826183221.GB3167@kroah.com>
References: <3F4A8027.6FE3F594@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev <netdev@oss.sgi.com>,
   Jeff Garzik <jgarzik@pobox.com>, "Feldman, Scott" <scott.feldman@intel.com>,
   Larry Kessler <kessler@us.ibm.com>, Randy Dunlap <rddunlap@osdl.org>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jim Keniston <jkenisto@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <3F4A8027.6FE3F594@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 25, 2003 at 02:31:19PM -0700, Jim Keniston wrote:
> +int __netdev_printk(const char *sevlevel, const struct net_device *netdev,
> +	int msglevel, const char *format, ...)
> +{
> +	if (!netdev || !format) {
> +		return -EINVAL;
> +	}
> +	if (msglevel == NETIF_MSG_ALL || (netdev->msg_enable & msglevel)) {
> +		char msg[512];

512 bytes on the stack?  Any way to prevent this from happening?  With
the push to make the stack even smaller in 2.7, people will not like
this.

thanks,

greg k-h
