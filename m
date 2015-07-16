From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [V2 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Thu, 16 Jul 2015 11:19:01 +0000
Message-ID: <d1e303ece500475b8e422d55f82fbffd@SIXPR30MB031.064d.mgd.msft.net>
References: <1436868048-17875-1-git-send-email-decui@microsoft.com>
 <20150715.211916.1258342954251964451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150715.211916.1258342954251964451.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller
> Sent: Thursday, July 16, 2015 12:19
> 
> From: Dexuan Cui
> Date: Tue, 14 Jul 2015 03:00:48 -0700
> 
> > +	pr_debug("hvsock_sk_destruct: called\n");
> 
> Debug logging just to state that a function is called is not appropriate,
> we have very sophisticated tracing facilities in the kernel that can do
> that transparently, and more.
> 
> Please remove this.
OK. 
 
> > +	if (hvsk->channel) {
> > +		pr_debug("hvsock_sk_destruct: calling vmbus_close()\n");
> 
> Likewise, these kinds of debug logs are totally inappropriate.
OK, I'll remove all the pr_debug() in the patch.
 
> > +static int hvsock_release(struct socket *sock)
> > +{
> > +	/* sock->sk is NULL, if accept() is interrupted by a signal */
> > +	if (sock->sk) {
> > +		__hvsock_release(sock->sk);
> > +		sock->sk = NULL;
> > +	}
> > +
> > +	sock->state = SS_FREE;
> > +	pr_debug("hvsock_release called\n\n");
> 
> Likewise.
OK. Will fix it.

Thanks,
-- Dexuan
