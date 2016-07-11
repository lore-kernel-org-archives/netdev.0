From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [patch net-next 1/2] devlink: add hardware messages tracing
 facility
Date: Mon, 11 Jul 2016 16:54:12 -0400
Message-ID: <20160711165412.0ba05675@gandalf.local.home>
References: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	yotamg@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
	ogerlitz@mellanox.com, ivecera@redhat.com, mingo@redhat.com,
	jolsa@kernel.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0153.hostedemail.com ([216.40.44.153]:60660 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932481AbcGKUyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 16:54:39 -0400
In-Reply-To: <1468243128-6669-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Jul 2016 15:18:47 +0200
Jiri Pirko <jiri@resnulli.us> wrote:

> diff --git a/include/net/devlink.h b/include/net/devlink.h
> index c99ffe8..865ade6 100644
> --- a/include/net/devlink.h
> +++ b/include/net/devlink.h
> @@ -115,6 +115,8 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size);
>  int devlink_register(struct devlink *devlink, struct device *dev);
>  void devlink_unregister(struct devlink *devlink);
>  void devlink_free(struct devlink *devlink);
> +void devlink_trace_hwmsg(const struct devlink *devlink, bool incoming,
> +			 unsigned long type, const u8 *buf, size_t len);
>  int devlink_port_register(struct devlink *devlink,
>  			  struct devlink_port *devlink_port,
>  			  unsigned int port_index);
> @@ -154,6 +156,12 @@ static inline void devlink_free(struct devlink *devlink)
>  	kfree(devlink);
>  }
>  
> +static inline void devlink_trace_hwmsg(const struct devlink *devlink,
> +				       bool incoming, unsigned long type,
> +				       const u8 *buf, size_t len);
> +{
> +}
> +

I'm assuming the !CONFIG_NET_DEVLINK was never tested, because the
above probably wont build, and if it did, it would be wrong.

-- Steve
