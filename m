From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFC ethtool usage
Date: Thu, 05 May 2005 22:32:43 -0400
Message-ID: <427AD74B.10904@pobox.com>
References: <20050505234128.GA21736@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Don Fry <brazilnut@us.ibm.com>
In-Reply-To: <20050505234128.GA21736@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don Fry wrote:
> One of the pieces of information that is useful for me when debugging
> problems with the pcnet32 driver, is which chip version the problem
> occurs with (79C973, 79C976, etc).
> 
> Since the chip has no firmware, how badly would I be flamed, if I
> modified the driver to return the string (which is currently printed
> on boot), as the 'firmware-version'?
> 
> --- orig.pcnet32.c      Mon May  2 15:12:02 2005
> +++ pcnet32.c   Mon May  2 15:13:38 2005
> @@ -559,6 +559,7 @@ static void pcnet32_get_drvinfo(struct n
>  
>      strcpy (info->driver, DRV_NAME);
>      strcpy (info->version, DRV_VERSION);
> +    strncpy(info->fw_version, lp->name, sizeof(info->fw_version) - 1);
>      if (lp->pci_dev)
>  	strcpy (info->bus_info, pci_name(lp->pci_dev));
>      else
> 
> So the output looked like:
> $ ethtool -i eth0
> driver: pcnet32
> version: 1.30j
> firmware-version: PCnet/PRO 79C976
> bus-info: 0000:00:01.0

Convenient in the short term, but misleading in the long run, IMO.

Surely you can get this info from an ethtool register dump?

	Jeff
