From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net-next:master 6/12] include/linux/usb/cdc.h:23: error:
 redefinition of 'struct usb_cdc_parsed_header'
Date: Thu, 17 Sep 2015 06:51:20 +0800
Message-ID: <20150916225120.GA18257@wfg-t540p.sh.intel.com>
References: <201509160310.FiynyPOo%fengguang.wu@intel.com>
 <20150915.132742.739418011603329556.davem@davemloft.net>
 <20150916130658.GB24184@wfg-t540p.sh.intel.com>
 <20150916.105454.1537994485794572085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: oneukum@suse.com, kbuild-all@01.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:16111 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752349AbbIPWvV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Sep 2015 18:51:21 -0400
Content-Disposition: inline
In-Reply-To: <20150916.105454.1537994485794572085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2015 at 10:54:54AM -0700, David Miller wrote:
> From: Fengguang Wu <fengguang.wu@intel.com>
> Date: Wed, 16 Sep 2015 21:06:58 +0800
> 
> > On Tue, Sep 15, 2015 at 01:27:42PM -0700, David Miller wrote:
> >> From: kbuild test robot <fengguang.wu@intel.com>
> >> Date: Wed, 16 Sep 2015 03:57:11 +0800
> >> 
> >> > All error/warnings (new ones prefixed by >>):
> >> > 
> >> >    In file included from drivers/usb/gadget/function/u_ether.h:20,
> >> >                     from drivers/usb/gadget/legacy/cdc2.c:16:
> >> >    include/linux/usb/cdc.h:47: warning: 'struct usb_interface' declared inside parameter list
> >> >    include/linux/usb/cdc.h:47: warning: its scope is only this definition or declaration, which is probably not what you want
> >> >    In file included from drivers/usb/gadget/function/u_serial.h:16,
> >> >                     from drivers/usb/gadget/legacy/cdc2.c:17:
> >> >>> include/linux/usb/cdc.h:23: error: redefinition of 'struct usb_cdc_parsed_header'
> >> >    include/linux/usb/cdc.h:47: warning: 'struct usb_interface' declared inside parameter list
> >> >>> include/linux/usb/cdc.h:47: error: conflicting types for 'cdc_parse_cdc_header'
> >> >    include/linux/usb/cdc.h:47: error: previous declaration of 'cdc_parse_cdc_header' was here
> >> 
> >> This may be a side effect of the initial warning, does this reproduce with
> >> that fixed?  Please show me what the warning looks like in that case.
> > 
> > Dave, net-next/master commit ad1e7b97b3 ("cdc: Fix build warning.")
> > still has errors.
> > 
> > The problem is, the header file <linux/usb/cdc.h> is included twice.
> 
> That's not possible after the patch I committed from Stephen Rothwell
> which adds proper include guards:

Yes, this patch fixed the errors nicely!

Thanks,
Fengguang

> ====================
> commit b84ee0d7f375ed7840c7c110d46eac24cf94b2a2
> Author: Stephen Rothwell <sfr@canb.auug.org.au>
> Date:   Wed Sep 16 11:10:16 2015 +1000
> 
>     cdc: add header guards
>     
>     Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/include/linux/usb/cdc.h b/include/linux/usb/cdc.h
> index 959d0c8..b5706f9 100644
> --- a/include/linux/usb/cdc.h
> +++ b/include/linux/usb/cdc.h
> @@ -7,6 +7,8 @@
>   * modify it under the terms of the GNU General Public License
>   * version 2 as published by the Free Software Foundation.
>   */
> +#ifndef __LINUX_USB_CDC_H
> +#define __LINUX_USB_CDC_H
>  
>  #include <uapi/linux/usb/cdc.h>
>  
> @@ -45,3 +47,5 @@ int cdc_parse_cdc_header(struct usb_cdc_parsed_header *hdr,
>  				struct usb_interface *intf,
>  				u8 *buffer,
>  				int buflen);
> +
> +#endif /* __LINUX_USB_CDC_H */
> diff --git a/include/uapi/linux/usb/cdc.h b/include/uapi/linux/usb/cdc.h
> index b6a9cdd..e2bc417 100644
> --- a/include/uapi/linux/usb/cdc.h
> +++ b/include/uapi/linux/usb/cdc.h
> @@ -6,8 +6,8 @@
>   * firmware based USB peripherals.
>   */
>  
> -#ifndef __LINUX_USB_CDC_H
> -#define __LINUX_USB_CDC_H
> +#ifndef __UAPI_LINUX_USB_CDC_H
> +#define __UAPI_LINUX_USB_CDC_H
>  
>  #include <linux/types.h>
>  
> @@ -444,4 +444,4 @@ struct usb_cdc_ncm_ndp_input_size {
>  #define USB_CDC_NCM_CRC_NOT_APPENDED			0x00
>  #define USB_CDC_NCM_CRC_APPENDED			0x01
>  
> -#endif /* __LINUX_USB_CDC_H */
> +#endif /* __UAPI_LINUX_USB_CDC_H */
