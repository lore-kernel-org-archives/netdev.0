From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v18 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Tue, 26 Jul 2016 03:09:16 +0000
Message-ID: <CO2PR03MB2182D011056AA151CCEF4EFFBF0E0@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CO2PR03MB2182FD2D8AED7FFC7608510FBF0B0@CO2PR03MB2182.namprd03.prod.outlook.com>
 <20160725.173701.1282720667210726281.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>,
	"cavery@redhat.com" <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	"rolf.neugebauer@docker.com" <rolf.neugebauer@docker.com>,
	"mkubecek@suse.cz" <mkubecek@suse.cz>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"dave.scott@docker.com" <dave.scott@docker.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160725.173701.1282720667210726281.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Sat, 23 Jul 2016 01:35:51 +0000
> 
> > +static struct sock *hvsock_create(struct net *net, struct socket *sock,
> > +				  gfp_t priority, unsigned short type)
> > +{
> > +	struct hvsock_sock *hvsk;
> > +	struct sock *sk;
> > +
> > +	sk = sk_alloc(net, AF_HYPERV, priority, &hvsock_proto, 0);
> > +	if (!sk)
> > +		return NULL;
>  ...
> > +	/* Looks stream-based socket doesn't need this. */
> > +	sk->sk_backlog_rcv = NULL;
> > +
> > +	sk->sk_state = 0;
> > +	sock_reset_flag(sk, SOCK_DONE);
> 
> All of these are unnecessary initializations, since sk_alloc() zeroes
> out the 'sk' object for you.

Hi David,
Thanks for the comment!  I'll remove the 3 lines.

May I know if you have more comments?

BTW, during the past month, at least 7 other people also reviewed
the patch and gave me quite a few good comments, which have
been addressed. Though only one of them gave the Reviewed-by
line for now, I guess I would get more if I ping them to have a look
at the latest version of the patch, i.e., v19 -- I'm going to post it
with the aforementioned 3 lines removed and if you've more 
comments, I'm ready to address them too. :-)

Thanks,
-- Dexuan
