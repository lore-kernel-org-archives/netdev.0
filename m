From: "Schmitt, Phillip J" <phillip.j.schmitt@intel.com>
Subject: RE: [Intel-wired-lan] [next PATCH 05/11] ixgbe: Simplify
 configuration of setting VLVF and VLVFB
Date: Thu, 10 Dec 2015 22:52:43 +0000
Message-ID: <305E19FFAC908240AB6DEBD1E2D8C1E180CF618F@ORSMSX108.amr.corp.intel.com>
References: <20151103005850.28233.63113.stgit@localhost.localdomain>
 <20151103010954.28233.65503.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Alexander Duyck <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5158 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643AbbLJWwp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 17:52:45 -0500
In-Reply-To: <20151103010954.28233.65503.stgit@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Intel-wired-lan [mailto:intel-wired-lan-bounces@lists.osuosl.org] On
> Behalf Of Alexander Duyck
> Sent: Monday, November 02, 2015 5:10 PM
> To: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: [Intel-wired-lan] [next PATCH 05/11] ixgbe: Simplify configuration of
> setting VLVF and VLVFB
> 
> This patch addresses several issues within the VLVF and VLVFB configuration
> 
> First was the fact that code was overly complicated with multiple conditional
> paths depending on if we adding or removing and which bit we were going to
> add or remove.  Instead of messing with all that I have simplified it by using (vid /
> 32) and (1 - vid / 32) to identify our register and the other vlvfb register.
> 
> Second was the fact that we were likely leaking a few packets into the PF in
> cases where we were deleting an entry and the VFTA filter for that entry as the
> ordering was such that we deleted the pool and then the VLAN filter instead of
> the other way around.  I have updated that by adding a check for no bits being
> set and if that occurs we clear things up in the proper order.
> 
> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>

Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
