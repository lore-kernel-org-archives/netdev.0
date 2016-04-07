From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v7 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Thu, 07 Apr 2016 04:29:33 -0700
Message-ID: <1460028573.6715.88.camel@perches.com>
References: <1460033410-28710-1-git-send-email-decui@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vkuznets@redhat.com
To: Dexuan Cui <decui@microsoft.com>, gregkh@linuxfoundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com,
	kys@microsoft.com, haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460033410-28710-1-git-send-email-decui@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-07 at 05:50 -0700, Dexuan Cui wrote:
> Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
> mechanism between the host and the guest. It's somewhat like TCP over
> VMBus, but the transportation layer (VMBus) is much simpler than IP.

style trivia:

> diff --git a/net/hv_sock/af_hvsock.c b/net/hv_sock/af_hvsock.c
[]
> +static struct sock *__hvsock_find_bound_socket(const struct sockaddr=
_hv *addr)
> +{
> +	struct hvsock_sock *hvsk;
> +=20
> +	list_for_each_entry(hvsk, &hvsock_bound_list, bound_list)
> +		if (uuid_equals(addr->shv_service_id,
> +				hvsk->local_addr.shv_service_id))
> +			return hvsock_to_sk(hvsk);

Because there's an if, it's generally nicer to use
braces in the list_for_each
> +static struct sock *__hvsock_find_connected_socket_by_channel(
> +	const struct vmbus_channel *channel)
> +{
> +	struct hvsock_sock *hvsk;
> +
> +	list_for_each_entry(hvsk, &hvsock_connected_list, connected_list)
> +		if (hvsk->channel =3D=3D channel)
> +			return hvsock_to_sk(hvsk);
> +	return NULL;

here too

> +static int hvsock_sendmsg(struct socket *sock, struct msghdr *msg, s=
ize_t len)
> +{
[]
> +	if (msg->msg_flags & ~MSG_DONTWAIT) {
> +		pr_err("hvsock_sendmsg: unsupported flags=3D0x%x\n",
> +		=A0=A0=A0=A0=A0=A0=A0msg->msg_flags);

All the pr_<level> messages with embedded function
names could use "%s:", __func__
