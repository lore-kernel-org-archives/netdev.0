From: Mauro Rodrigues <maurosr@linux.vnet.ibm.com>
Subject: Re: [net-intel-i40e] question about assignment overwrite
Date: Wed, 7 Jun 2017 16:55:27 -0300
Message-ID: <20170607195526.GA26867@korriban>
References: <20170517154858.Horde.xMvsIEhHNSGu52mfyp7HA3R@gator4166.hostgator.com>
 <1495086551.46489.1.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Gustavo A. R. Silva" <garsilva@embeddedor.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:59623 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751252AbdFGTzi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:55:38 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v57Js8gA132894
        for <netdev@vger.kernel.org>; Wed, 7 Jun 2017 15:55:38 -0400
Received: from e24smtp03.br.ibm.com (e24smtp03.br.ibm.com [32.104.18.24])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2axptq32qv-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 15:55:37 -0400
Received: from localhost
        by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <maurosr@linux.vnet.ibm.com>;
        Wed, 7 Jun 2017 16:55:35 -0300
Content-Disposition: inline
In-Reply-To: <1495086551.46489.1.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 17, 2017 at 10:49:11PM -0700, Jeff Kirsher wrote:
> On Wed, 2017-05-17 at 15:48 -0500, Gustavo A. R. Silva wrote:
> > While looking into Coverity ID 1408956 I ran into the following
> > piece  
> > of code at drivers/net/ethernet/intel/i40e/i40e_main.c:8807:
> > 
> > 8807        if (pf->hw.mac.type == I40E_MAC_X722) {
> > 8808                pf->flags |= I40E_FLAG_RSS_AQ_CAPABLE
> > 8809                             | I40E_FLAG_128_QP_RSS_CAPABLE
> > 8810                             | I40E_FLAG_HW_ATR_EVICT_CAPABLE
> > 8811                             | I40E_FLAG_OUTER_UDP_CSUM_CAPABLE
> > 8812                             | I40E_FLAG_WB_ON_ITR_CAPABLE
> > 8813                             |
> > I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE
> > 8814                             | I40E_FLAG_NO_PCI_LINK_CHECK
> > 8815                             | I40E_FLAG_USE_SET_LLDP_MIB
> > 8816                             | I40E_FLAG_GENEVE_OFFLOAD_CAPABLE
> > 8817                             | I40E_FLAG_PTP_L4_CAPABLE
> > 8818                             | I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE;
> > 8819        } else if ((pf->hw.aq.api_maj_ver > 1) ||
> > 8820                   ((pf->hw.aq.api_maj_ver == 1) &&
> > 8821                    (pf->hw.aq.api_min_ver > 4))) {
> > 8822                /* Supported in FW API version higher than 1.4 */
> > 8823                pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
> > 8824                pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
> > 8825        } else {
> > 8826                pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
> > 8827        }
> > 
> > The issue here is that the assignment at line 8823 is overwritten
> > by  
> > the code at line 8824.
> > 
> > I'm suspicious that line 8824 should be remove and a patch like the  
> > following can be applied:
> > 
> > index d5c9c9e..48ffa73 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > @@ -8821,7 +8821,6 @@ static int i40e_sw_init(struct i40e_pf *pf)
> >                      (pf->hw.aq.api_min_ver > 4))) {
> >                  /* Supported in FW API version higher than 1.4 */
> >                  pf->flags |= I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
> > -               pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
> >          } else {
> >                  pf->flags = I40E_FLAG_HW_ATR_EVICT_CAPABLE;
> >          }
> > 
> > What do you think?
> 
> This issue is already fixed in my dev-queue branch on my next-queue
> tree.

Hi Jeff, are you planning to push this fix into net branch anytime soon?

Thanks,

Mauro
