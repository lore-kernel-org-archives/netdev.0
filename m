From: "Brady, Alan" <alan.brady@intel.com>
Subject: RE: [net-next 11/15] i40evf: Enable VF to request an alternate
 queue allocation
Date: Mon, 2 Oct 2017 21:35:51 +0000
Message-ID: <C8326AE922E1A04D91DF73B4913A8DCB2CA550D7@ORSMSX108.amr.corp.intel.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
 <20171002194852.71970-12-jeffrey.t.kirsher@intel.com>
 <AM0PR0502MB368318470E6010AB9D6C07E1BF7D0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Yuval Mintz <yuvalm@mellanox.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:39927 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751174AbdJBVfx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 17:35:53 -0400
In-Reply-To: <AM0PR0502MB368318470E6010AB9D6C07E1BF7D0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Yuval Mintz [mailto:yuvalm@mellanox.com]
> Sent: Monday, October 2, 2017 1:51 PM
> To: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; davem@davemloft.net
> Cc: Brady, Alan <alan.brady@intel.com>; netdev@vger.kernel.org;
> nhorman@redhat.com; sassmann@redhat.com; jogreene@redhat.com
> Subject: RE: [net-next 11/15] i40evf: Enable VF to request an alternate queue
> allocation
> 
> > +	case VIRTCHNL_OP_REQUEST_QUEUES: {
> > +		struct virtchnl_vf_res_request *vfres =
> > +			(struct virtchnl_vf_res_request *)msg;
> > +		if (vfres->num_queue_pairs == adapter->num_req_queues)
> > {
> > +			adapter->flags |=
> > I40EVF_FLAG_REINIT_ITR_NEEDED;
> > +			i40evf_schedule_reset(adapter);
> > +		} else {
> > +			dev_info(&adapter->pdev->dev,
> > +				 "Requested %d queues, PF can support
> > %d\n",
> > +				 adapter->num_req_queues,
> > +				 vfres->num_queue_pairs);
> > +			adapter->num_req_queues = 0;
> > +		}
> > +		}
> > +		break;
> 
> Something is odd about your parenthesis.
> 
> >  	default:
> >  		if (adapter->current_op && (v_opcode != adapter-
> > >current_op))
> >  			dev_warn(&adapter->pdev->dev, "Expected
> response %d from PF,
> > received %d\n",
> > --
> > 2.14.2

I'm not sure which parentheses you are referring to.  Perhaps you mean the double curly braces?  The outer set of braces are creating a block in the case statement so we can declare a variable specific to the case statement.  The inner brace is an if/else statement block.  They are both consistent with brace usage/alignment in the rest of the file and adding a new line between them generates a GCC warning.

-Alan
