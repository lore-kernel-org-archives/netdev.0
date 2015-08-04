From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] igb: do not re-init SR-IOV during probe
Date: Tue, 4 Aug 2015 22:15:43 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81ADF460@ORSMSX101.amr.corp.intel.com>
References: <1436533272-18070-1-git-send-email-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62587 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbbHDWPp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 18:15:45 -0400
In-Reply-To: <1436533272-18070-1-git-send-email-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Stefan Assmann
> Sent: Friday, July 10, 2015 6:01 AM
> To: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org; Kirsher, Jeffrey T; sassmann@kpanic.de
> Subject: [PATCH] igb: do not re-init SR-IOV during probe
> 
> During driver probing the following code path is triggered.
> igb_probe
> ->igb_sw_init
>   ->igb_probe_vfs
>     ->igb_pci_enable_sriov
>       ->igb_sriov_reinit
> 
> Doing the SR-IOV re-init is not necessary during probing since we're
> starting from scratch. Here we can call igb_enable_sriov() right away.
> 
> Running igb_sriov_reinit() during igb_probe() also seems to cause
> occasional packet loss on some onboard 82576 NICs. Reproduced on
> Dell and HP servers with onboard 82576 NICs.
> Example:
> Intel Corporation 82576 Gigabit Network Connection [8086:10c9] (rev 01)
> Subsystem: Dell Device [1028:0481]
> 
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
