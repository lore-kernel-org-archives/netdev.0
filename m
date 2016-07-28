From: Lukas Wunner <lukas@wunner.de>
Subject: Re: [PATCH v5 5/8] thunderbolt: Networking state machine
Date: Thu, 28 Jul 2016 13:35:50 +0200
Message-ID: <20160728113550.GA1701@wunner.de>
References: <1469693721-5641-1-git-send-email-amir.jer.levy@intel.com>
 <1469693721-5641-6-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, corbet@lwn.net, linux-kernel@vger.kernel.org,
	linux-pci@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1469693721-5641-6-git-send-email-amir.jer.levy@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 28, 2016 at 11:15:18AM +0300, Amir Levy wrote:
> +static void nhi_handle_notification_msg(struct tbt_nhi_ctxt *nhi_ctxt,
> +					const u8 *msg)
> +{
> +	struct port_net_dev *port;
> +	u8 port_num;
> +
> +#define INTER_DOMAIN_LINK_SHIFT 0
> +#define INTER_DOMAIN_LINK_MASK	GENMASK(2, INTER_DOMAIN_LINK_SHIFT)
> +	switch (msg[3]) {
> +
> +	case NC_INTER_DOMAIN_CONNECTED:
> +		port_num = PORT_NUM_FROM_MSG(msg[5]);
> +#define INTER_DOMAIN_APPROVED BIT(3)
> +		if (likely(port_num < nhi_ctxt->num_ports)) {
> +			if (!(msg[5] & INTER_DOMAIN_APPROVED))

I find these interspersed #defines make the code hard to read,
but maybe that's just me.


> +				nhi_ctxt->net_devices[
> +					port_num].medium_sts =

Looks like a carriage return slipped in here.

In patch [4/8], I've found it a bit puzzling that FW->SW responses and
FW->SW notifications are defined in icm_nhi.c, whereas SW->FW commands
are defined in net.h. It would perhaps be more logical to have them
all in the header file. The FW->SW responses and SW->FW commands are
almost identical, there are odd spelling differences (CONNEXION vs.
CONNECTION).

It would probably be good to explain the PDF acronym somewhere.

I've skimmed over all patches in the series, too superficial to provide
a Reviewed-by, it's just too much code to review thoroughly and I also
lack the hardware to test it, but broadly this LGTM.

Thanks,

Lukas
