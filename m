From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH 0/2] i40e: fix firmware update
Date: Fri, 1 Sep 2017 19:19:39 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5882A98333@ORSMSX115.amr.corp.intel.com>
References: <20170901140234.7840-1-sassmann@kpanic.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Stefan Assmann <sassmann@kpanic.de>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:33794 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751715AbdIATTm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 15:19:42 -0400
In-Reply-To: <20170901140234.7840-1-sassmann@kpanic.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Stefan Assmann
> Sent: Friday, September 01, 2017 7:03 AM
> To: intel-wired-lan@lists.osuosl.org
> Cc: netdev@vger.kernel.org; davem@davemloft.net; Kirsher, Jeffrey T
> <jeffrey.t.kirsher@intel.com>; sassmann@kpanic.de
> Subject: [PATCH 0/2] i40e: fix firmware update
> 
> The first patch fixes the firmware update which is currently broken and
> results in a bad flash (corrupt firmware). Recovery is possible with a
> fixed driver.
> The second patch reverts a commit that causes the firmware checksum
> verification to fail right after a successful flash. This is related to
> a recent workqueue change. Haven't gotten to the bottom of this yet, but
> for the sake of a smooth firmware update experience let's revert the
> commit for now.

Hi Stefan,

Thanks for these patches, I apologize for the time it took for us to respond to this. 

The first patch is functionally correct, and I'm surprised we missed sending an equivalent ourselves. It looks like some related changes occurred around this code, and we failed to submit the patch.

I think Jeff would prefer if we send the version based directly on the out-of-tree code, which I will be reviving and submitting shortly.

The second issue I believe is not fixed correctly by the patch, I'm unsure why exactly changing the WQ would cause this but I believe that a similar patch which creates a non-locked version of i40e_nvm_read_buffer() will resolve this, and I will be sending that patch as well, which I believe is the real fix versus halting the work queue.

Thanks,
Jake

> 
> Stefan Assmann (2):
>   i40e: use non-locking i40e_read_nvm_word() function during nvmupdate
>   Revert "i40e: remove WQ_UNBOUND and the task limit of our workqueue"
> 
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 12 +++++-------
>  drivers/net/ethernet/intel/i40e/i40e_nvm.c  | 24 ++++++++++++++++++++++--
>  2 files changed, 27 insertions(+), 9 deletions(-)
> 
> --
> 2.13.5
