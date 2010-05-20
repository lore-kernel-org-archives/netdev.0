From: Henning Fehrmann <henning.fehrmann@aei.mpg.de>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Thu, 20 May 2010 10:16:01 +0000
Message-ID: <20100520101601.GA26235@localhost>
References: <4BEDCD87.4090602@kernel.org>
 <20100518131216.GA24750@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ox1.aei.mpg.de ([194.94.224.6]:34871 "EHLO ox1.aei.mpg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755474Ab0ETKQW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 May 2010 06:16:22 -0400
In-Reply-To: <20100518131216.GA24750@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hello,
> 
> 
> Let me re-describe the symptoms.
> I am not loading any ipmi related modules and not the netconsole
> module.
> When booting out current 2.6.32 kernel we can not access the IPMI
> remotely.
> 
> We had one case where the IPMI card was accessible while using this
> kernel but probably due to the fact that eth0 was removed. We do not
> consider this case anymore. 
> 
> This problem does not occur when using an older kernel. 
> 
> It has likely nothing to do with netconsole.
> 
> Here is the bisecting result:
> 
> The sha1 sum of the first bad commit is: 
> 6e50912a442947d5fafd296ca6fdcbeb36b163ff
> 
> Hence, the last good commit has:
> b2f8f7525c8aa1fdd8ad8c72c832dfb571d5f768

I 'reverse patched' the changes: 

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index e909f96..1342e0b 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -427,6 +427,8 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
                        e1000_validate_option(&crc_stripping, &opt, adapter);
                        if (crc_stripping == OPTION_ENABLED)
                                adapter->flags2 |= FLAG2_CRC_STRIPPING;
+               } else {
+                       adapter->flags2 |= FLAG2_CRC_STRIPPING;
                }
        }
        { /* Kumeran Lock Loss Workaround */


and compiled the kernel. This kernel works and the IPMI card is remotely accessible. 

Can we savely remove this two lines or are we running into other problems?

Cheers,
Henning
