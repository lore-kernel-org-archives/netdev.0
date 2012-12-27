From: "Qin, Xiaohong" <Xiaohong.Qin@emc.com>
Subject: RE: vxlan in Linux kernel 3.7
Date: Thu, 27 Dec 2012 13:56:51 -0500
Message-ID: <A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12C@MX01A.corp.emc.com>
References: <A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12B@MX01A.corp.emc.com>
 <20121227104916.4fb2af04@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hop-nat-141.emc.com ([168.159.213.141]:34318 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751963Ab2L0S5Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 13:57:24 -0500
In-Reply-To: <20121227104916.4fb2af04@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

Thanks very much for the tip. Here is the output on my box,

/sbin/modinfo vxlan
filename:       /lib/modules/3.7.0-030700-generic/kernel/drivers/net/vxlan.ko
alias:          rtnl-link-vxlan
author:         Stephen Hemminger <shemminger@vyatta.com>
version:        0.1
license:        GPL
srcversion:     D5253D8FFAF3FEF6A3A3026
depends:
intree:         Y
vermagic:       3.7.0-030700-generic SMP mod_unload modversions
parm:           udp_port:Destination UDP port (uint)
parm:           log_ecn_error:Log packets received with corrupted ECN (bool)

# ip -V
ip utility, iproute2-ss111117

So I think I'm all set to give it a try?

Thanks.

Dennis Qin

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Stephen Hemminger
Sent: Thursday, December 27, 2012 10:49 AM
To: Qin, Xiaohong
Cc: netdev@vger.kernel.org
Subject: Re: vxlan in Linux kernel 3.7

On Thu, 27 Dec 2012 13:42:51 -0500
"Qin, Xiaohong" <Xiaohong.Qin@emc.com> wrote:

> Hi All,
> 
> I have installed kernel 3.7 on my Linux box, see the following uname 
> -a output,
> 
> uname -a
> Linux c210-m2-sib-3 3.7.0-030700-generic #201212102335 SMP Tue Dec 11 
> 04:36:24 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
> 
> Does that mean I've got VXLAN module loaded or I still need to go through some extra steps to enable or configure it? Do you have any VXLAN setup or configuration document by chance?
> 
> Thanks.
> 
> Dennis Qin
> 
> P.S. If this is not the right place to ask this kind of questions, please let me know which mailing list I should use.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in 
> the body of a message to majordomo@vger.kernel.org More majordomo info 
> at  http://vger.kernel.org/majordomo-info.html

VXLAN driver is part of the kernel config. 
If using a vendor supplied kernel, most likely it is available as a module.
Try:
   /sbin/modinfo vxlan
If you see 'ERROR: Module vxlan not found' then vxlan was not configured.
You will also need to have current iproute2 utilities.
   $ ip -V
ip utility, iproute2-ss121211
--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
