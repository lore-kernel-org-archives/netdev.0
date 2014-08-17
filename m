From: Dmitry Popov <ixaphire@qrator.net>
Subject: Re: [PATCH net] tipc: fix message importance range check
Date: Sun, 17 Aug 2014 15:00:03 +0400
Message-ID: <20140817150003.586becdcec969d0f4625595e@qrator.net>
References: <1408113875-30655-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <erik.hugne@ericsson.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33371 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbaHQLAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2014 07:00:08 -0400
Received: by mail-lb0-f169.google.com with SMTP id s7so3247430lbd.14
        for <netdev@vger.kernel.org>; Sun, 17 Aug 2014 04:00:06 -0700 (PDT)
In-Reply-To: <1408113875-30655-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Aug 2014 16:44:35 +0200
<erik.hugne@ericsson.com> wrote:

> -static inline void tipc_port_set_importance(struct tipc_port *port, int imp)
> +static inline int tipc_port_set_importance(struct tipc_port *port, int imp)
>  {
> +	if (imp > TIPC_CRITICAL_IMPORTANCE)
> +		return -EINVAL
>  	msg_set_importance(&port->phdr, (u32)imp);
>  }

1) Semicolon is missing after return -EINVAL,
2) return 0 is missing at the end of this function.
