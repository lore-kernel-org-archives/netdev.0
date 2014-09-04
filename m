From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net-timestamp: expand documentation
Date: Thu, 04 Sep 2014 14:56:04 +0200
Message-ID: <54086164.6030603@redhat.com>
References: <1409534867-32710-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2261 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771AbaIDM4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 08:56:08 -0400
In-Reply-To: <1409534867-32710-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willem,

On 09/01/2014 03:27 AM, Willem de Bruijn wrote:
> Expand Documentation/networking/timestamping.txt with new
> interfaces and bytestream timestamping. Also minor
> cleanup of the other text.
>
> Import txtimestamp.c test of the new features.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
...
> +static int recv_errmsg(int fd)
> +{
> +	static char ctrl[1024 /* overprovision*/];
> +	static struct msghdr msg;
> +	struct iovec entry;
> +	static char *data;
> +	int ret = 0;
> +
> +	data = malloc(cfg_payload_len);
> +	if (!data)
> +		error(1, 0, "malloc");
> +
> +	memset(&msg, 0, sizeof(msg));
> +	memset(&entry, 0, sizeof(entry));
> +	memset(ctrl, 0, sizeof(ctrl));
> +	memset(data, 0, sizeof(data));

I think this memset is wrong and should rather be
something like :

	memset(data, 0, cfg_payload_len);

> +	entry.iov_base = data;
> +	entry.iov_len = cfg_payload_len;
> +	msg.msg_iov = &entry;
> +	msg.msg_iovlen = 1;
> +	msg.msg_name = NULL;
> +	msg.msg_namelen = 0;
> +	msg.msg_control = ctrl;
> +	msg.msg_controllen = sizeof(ctrl);
