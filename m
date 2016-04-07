From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v7 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Thu, 7 Apr 2016 11:47:26 +0000
Message-ID: <BLUPR03MB1410D45626651C78FD8C3918BF900@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1460033410-28710-1-git-send-email-decui@microsoft.com>
 <1460028573.6715.88.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: Joe Perches <joe@perches.com>, "gregkh@linuxfoundation.org"
 <gregkh@linuxfoundation.org>, "davem@davemloft.net" <davem@davemloft.net>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>, KY Srinivasan
 <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1460028573.6715.88.camel@perches.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> From: Joe Perches [mailto:joe@perches.com]
> Sent: Thursday, April 7, 2016 19:30
> To: Dexuan Cui <decui@microsoft.com>; gregkh@linuxfoundation.org;
> davem@davemloft.net; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com; KY Srinivasan <kys@microsoft.com>; Haiyang Zhang
> <haiyangz@microsoft.com>
> Cc: vkuznets@redhat.com
> Subject: Re: [PATCH v7 net-next 1/1] hv_sock: introduce Hyper-V Sockets
> =

> On Thu, 2016-04-07 at 05:50 -0700, Dexuan Cui wrote:
> > Hyper-V Sockets (hv_sock) supplies a byte-stream based communication
> > mechanism between the host and the guest. It's somewhat like TCP over
> > VMBus, but the transportation layer (VMBus) is much simpler than IP.
> =

> style trivia:
> =

> > diff --git a/net/hv_sock/af_hvsock.c b/net/hv_sock/af_hvsock.c
> []
> > +static struct sock *__hvsock_find_bound_socket(const struct sockaddr_hv
> *addr)
> > +{
> > +	struct hvsock_sock *hvsk;
> > +
> > +	list_for_each_entry(hvsk, &hvsock_bound_list, bound_list)
> > +		if (uuid_equals(addr->shv_service_id,
> > +				hvsk->local_addr.shv_service_id))
> > +			return hvsock_to_sk(hvsk);
> =

> Because there's an if, it's generally nicer to use
> braces in the list_for_each

Thanks for the suggestion, Joe!
I'll add {}.

> > +static struct sock *__hvsock_find_connected_socket_by_channel(
> > +	const struct vmbus_channel *channel)
> > +{
> > +	struct hvsock_sock *hvsk;
> > +
> > +	list_for_each_entry(hvsk, &hvsock_connected_list, connected_list)
> > +		if (hvsk->channel =3D=3D channel)
> > +			return hvsock_to_sk(hvsk);
> > +	return NULL;
> =

> here too
I'll fix this too.

> > +static int hvsock_sendmsg(struct socket *sock, struct msghdr *msg, siz=
e_t len)
> > +{
> []
> > +	if (msg->msg_flags & ~MSG_DONTWAIT) {
> > +		pr_err("hvsock_sendmsg: unsupported flags=3D0x%x\n",
> > +		=A0=A0=A0=A0=A0=A0=A0msg->msg_flags);
> =

> All the pr_<level> messages with embedded function
> names could use "%s:", __func__
I'll fix this.

Thanks,
-- Dexuan
