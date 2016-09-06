From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2 6/6] net/mlx5: Add handling for port module
 event
Date: Tue, 06 Sep 2016 09:15:10 -0700
Message-ID: <1473178510.8300.10.camel@perches.com>
References: <1473177852-10711-1-git-send-email-saeedm@mellanox.com>
         <1473177852-10711-7-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Huy Nguyen <huyn@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0085.hostedemail.com ([216.40.44.85]:42391 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933625AbcIFQPP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 12:15:15 -0400
In-Reply-To: <1473177852-10711-7-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-06 at 19:04 +0300, Saeed Mahameed wrote:
> From: Huy Nguyen <huyn@mellanox.com>

[]

> +void mlx5_port_module_event(struct mlx5_core_dev *dev, struct mlx5_eqe *eqe)
> +{
> > +	struct mlx5_eqe_port_module *module_event_eqe;
> > +	u8 module_status;
> > +	u8 module_num;
> > +	u8 error_type;
> +
> > +	module_event_eqe = &eqe->data.port_module;
> > +	module_num = module_event_eqe->module;
> > +	module_status = module_event_eqe->module_status &
> > +			PORT_MODULE_EVENT_MODULE_STATUS_MASK;
> > +	error_type = module_event_eqe->error_type &
> > +		     PORT_MODULE_EVENT_ERROR_TYPE_MASK;
> +
> > +	switch (module_status) {
> > +	case MLX5_MODULE_STATUS_PLUGGED:
> +		mlx5_core_info(dev, "Module %u, status: plugged", module_num);


Missing format '\n' line terminations

> +		break;
> +
> > +	case MLX5_MODULE_STATUS_UNPLUGGED:
> > +		mlx5_core_info(dev, "Module %u, status: unplugged", module_num);
> > +		break;
> +
> > +	case MLX5_MODULE_STATUS_ERROR:
> > +		mlx5_core_info(dev, "Module %u, status: error, %s", module_num,
> > +			       mlx5_port_event_error_type_to_string(error_type));
> > +		break;
> +
> > +	default:
> > +		mlx5_core_info(dev, "Module %u, unknown module status %x",
> > +			       module_num, module_status);
> +	}

Should any of these be ratelimited?
