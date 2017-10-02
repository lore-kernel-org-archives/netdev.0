From: Yuval Mintz <yuvalm@mellanox.com>
Subject: RE: [net-next 11/15] i40evf: Enable VF to request an alternate queue
 allocation
Date: Mon, 2 Oct 2017 20:50:49 +0000
Message-ID: <AM0PR0502MB368318470E6010AB9D6C07E1BF7D0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
References: <20171002194852.71970-1-jeffrey.t.kirsher@intel.com>
 <20171002194852.71970-12-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Alan Brady <alan.brady@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:48832
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750984AbdJBUuw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 16:50:52 -0400
In-Reply-To: <20171002194852.71970-12-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	case VIRTCHNL_OP_REQUEST_QUEUES: {
> +		struct virtchnl_vf_res_request *vfres =3D
> +			(struct virtchnl_vf_res_request *)msg;
> +		if (vfres->num_queue_pairs =3D=3D adapter->num_req_queues)
> {
> +			adapter->flags |=3D
> I40EVF_FLAG_REINIT_ITR_NEEDED;
> +			i40evf_schedule_reset(adapter);
> +		} else {
> +			dev_info(&adapter->pdev->dev,
> +				 "Requested %d queues, PF can support
> %d\n",
> +				 adapter->num_req_queues,
> +				 vfres->num_queue_pairs);
> +			adapter->num_req_queues =3D 0;
> +		}
> +		}
> +		break;

Something is odd about your parenthesis.

>  	default:
>  		if (adapter->current_op && (v_opcode !=3D adapter-
> >current_op))
>  			dev_warn(&adapter->pdev->dev, "Expected
> response %d from PF, received %d\n",
> --
> 2.14.2
