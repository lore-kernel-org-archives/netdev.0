From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 3/4] SUNRPC: service destruction in network namespace
 context
Date: Fri, 27 Jan 2012 19:21:18 +0400
Message-ID: <4F22C0EE.4090701@parallels.com>
References: <20120125134132.13662.83447.stgit@localhost6.localdomain6> <20120125134726.13662.97179.stgit@localhost6.localdomain6> <20120126211450.GD700@fieldses.org> <4F226976.5000605@parallels.com> <20120127143335.GB9439@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120127143335.GB9439@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27.01.2012 18:33, J. Bruce Fields =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> OK, so at this point svc_close_net(serv, current->nsproxy->net_ns) is
> enough to clear out sv_permsocks and sv_temp_socks because we know th=
at
> the only sockets left are in that namespace.  Got it.
>

BTW, is this approach looks suitable for NFSd service?

> I'm not sure.  The one thing that might have helped mere here would b=
e
> a comment to explain what's going on, maybe something like:
>
> 	svc_close_net(serv, net);
> +	/*
> +	 * The last user is gone, so the only sockets left belonged its
> +	 * network namespace:
> +	 */
> 	BUG_ON(!list_empty(&serv->sv_permsocks));
> 	BUG_ON(!list_empty(&serv->sv_tempsocks));

Ok, can do so.


--=20
Best regards,
Stanislav Kinsbursky
