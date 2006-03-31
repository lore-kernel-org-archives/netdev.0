From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH]: e1000: prevent statistics from getting garbled during
	reset.
Date: Thu, 30 Mar 2006 21:46:54 -0800
Message-ID: <20060331054654.GA6632@kroah.com>
References: <20060330213928.GQ2172@austin.ibm.com>
	<20060331000208.GS2172@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, linuxppc-dev@ozlabs.org,
	john.ronciak@intel.com, jeffrey.t.kirsher@intel.com,
	linux-pci@atrey.karlin.mff.cuni.cz, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060331000208.GS2172@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2006 at 06:02:08PM -0600, Linas Vepstas wrote:
> -	/* Prevent stats update while adapter is being reset */
> +	/* Prevent stats update while adapter is being reset,
> +	 * or if the pci connection is down. */
>  	if (adapter->link_speed == 0)
>  		return;
> +   if (pdev->error_state && pdev->error_state != pci_channel_io_normal)
> +		return;

Coding style is still wrong here :(

(hint, use a tab...)

thanks,

greg k-h
