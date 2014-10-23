From: Joe Perches <joe@perches.com>
Subject: Re: [net] i40e: _MASK vs _SHIFT typo in i40e_handle_mdd_event()
Date: Wed, 22 Oct 2014 20:22:24 -0700
Message-ID: <1414034544.15751.2.camel@perches.com>
References: <1414033589-7544-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Dan Carpenter <dan.carpenter@oracle.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0227.hostedemail.com ([216.40.44.227]:38329 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932381AbaJWDW2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 23:22:28 -0400
In-Reply-To: <1414033589-7544-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 20:06 -0700, Jeff Kirsher wrote:
> We accidentally mask by the _SHIFT variable.  It means that "event" is
> always zero.
[]
> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
[]
> @@ -6151,7 +6151,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
>  				I40E_GL_MDET_TX_PF_NUM_SHIFT;
>  		u8 vf_num = (reg & I40E_GL_MDET_TX_VF_NUM_MASK) >>
>  				I40E_GL_MDET_TX_VF_NUM_SHIFT;
> -		u8 event = (reg & I40E_GL_MDET_TX_EVENT_SHIFT) >>
> +		u8 event = (reg & I40E_GL_MDET_TX_EVENT_MASK) >>
>  				I40E_GL_MDET_TX_EVENT_SHIFT;
>  		u8 queue = (reg & I40E_GL_MDET_TX_QUEUE_MASK) >>
>  				I40E_GL_MDET_TX_QUEUE_SHIFT;
> @@ -6165,7 +6165,7 @@ static void i40e_handle_mdd_event(struct i40e_pf *pf)
>  	if (reg & I40E_GL_MDET_RX_VALID_MASK) {
>  		u8 func = (reg & I40E_GL_MDET_RX_FUNCTION_MASK) >>
>  				I40E_GL_MDET_RX_FUNCTION_SHIFT;
> -		u8 event = (reg & I40E_GL_MDET_RX_EVENT_SHIFT) >>
> +		u8 event = (reg & I40E_GL_MDET_RX_EVENT_MASK) >>
>  				I40E_GL_MDET_RX_EVENT_SHIFT;
>  		u8 queue = (reg & I40E_GL_MDET_RX_QUEUE_MASK) >>
>  				I40E_GL_MDET_RX_QUEUE_SHIFT;

It might be useful to have a macro for that.
Something like:

#define GET_REG_VAL(reg, type)			\
	((reg & type##_MASK) >> type##_SHIFT)

so these could become:

	u8 vf_num = GET_REG_VAL(reg, I40E_GL_MDET_TX_VF_NUM);
	u8 event = GET_REG_VAL(reg, I40E_GL_MDET_TX_EVENT);

etc...
