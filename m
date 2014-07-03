From: "Williams, Mitch A" <mitch.a.williams@intel.com>
Subject: RE: [net-next 04/14] i40e: tolerate lost interrupts
Date: Thu, 3 Jul 2014 18:45:26 +0000
Message-ID: <AAEA33E297BCAC4B9BB20A7C2DF0AB8D656E4ECC@FMSMSX113.amr.corp.intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1404355233-30123-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <53B54957.70408@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41687 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759231AbaGCSpm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 14:45:42 -0400
In-Reply-To: <53B54957.70408@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com]
> Sent: Thursday, July 03, 2014 5:15 AM
> To: davem@davemloft.net; Williams, Mitch A
> Cc: Kirsher, Jeffrey T; netdev@vger.kernel.org; nhorman@redhat.com;
> sassmann@redhat.com
> Subject: Re: [net-next 04/14] i40e: tolerate lost interrupts
> 
> Hello.
> 
> On 07/03/2014 06:40 AM, Jeff Kirsher wrote:
> 
> > From: Mitch Williams <mitch.a.williams@intel.com>
> 
> > If the AQ interrupt gets lost for some reason, VF communications will
> > stall as the VFs have no way of reaching the PF, which is essentially
> > deaf. The VFs end up waiting forever for a reply that will never come.
> 
> > To alleviate this condition, go ahead and check the ARQ every time we
> > run the service task. Remove the check for a pending event, and get rid
> > of a chatty error message that is now meaningless.
> 
> > Change-ID: I0fc9d18169cd45c98f60188aef872cd6cee9a027
> > Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> > Tested-by: Jim Young <jamesx.m.young@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >   drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++------
> >   1 file changed, 2 insertions(+), 6 deletions(-)
> 
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
> b/drivers/net/ethernet/intel/i40e/i40e_main.c
> > index 440b671..88704c0 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> [...]
> > @@ -5360,10 +5357,9 @@ static void i40e_clean_adminq_subtask(struct
> i40e_pf *pf)
> >   	do {
> >   		event.msg_size = I40E_MAX_AQ_BUF_SIZE; /* reinit each time */
> >   		ret = i40e_clean_arq_element(hw, &event, &pending);
> > -		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
> > -			dev_info(&pf->pdev->dev, "No ARQ event found\n");
> > +		if (ret == I40E_ERR_ADMIN_QUEUE_NO_WORK)
> >   			break;
> > -		} else if (ret) {
> > +		else if (ret) {
> 
>     Keep {} around both arms of the *if* statement please, according to the
> kernel coding style.

Thanks for the review, Sergei. I have a list of several such minor coding-style issues, and I plan to send out a "scrub the i40evf driver" patch later this month.

-Mitch


> 
> >   			dev_info(&pf->pdev->dev, "ARQ event error %d\n", ret);
> >   			break;
> >   		}
> >
> 
> WBR, Sergei
