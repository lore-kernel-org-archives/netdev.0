From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv4 RFC net-next 1/4] sunvnet: NAPIfy sunvnet
Date: Wed, 15 Oct 2014 14:51:03 -0400
Message-ID: <543EC217.6060306@oracle.com>
References: <20141015180115.GH11840@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	davem@davemloft.net, bob.picco@oracle.com, dwight.engen@oracle.com,
	raghuram.kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41613 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751324AbaJOSvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 14:51:08 -0400
In-Reply-To: <20141015180115.GH11840@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/15/2014 02:01 PM, Sowmini Varadhan wrote:

> @@ -482,13 +485,26 @@ static int vnet_walk_rx(struct vnet_port *port, struct vio_dring_state *dr,
>  				return err;
>  			ack_start = -1;
>  		}
> +		if ((*npkts) >= budget) {
> +			send_ack = false;
> +			break;
> +		}
>  	}

I still don't like this-- it's virtually "boolean_variable = true;if (condition) boolean_variable = false".
Yes, it has the extra "break;", but I think it's clearer to say "send an ACK when
we're under budget; don't send an ACK and break when we're over," or:

		send_ack = *npkts < budget;
		if (!send_ack)
			break;

I can live with either way, though.

Acked-by: David L Stevens <david.stevens@oracle.com>

						+-DLS
