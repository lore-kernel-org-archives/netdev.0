From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [V2 6/7] hvsock: introduce Hyper-V VM Sockets feature
Date: Mon, 20 Jul 2015 05:30:50 +0000
Message-ID: <c56c82d2455f4183a51cd414edc0a9b1@SIXPR30MB031.064d.mgd.msft.net>
References: <1436868048-17875-1-git-send-email-decui@microsoft.com>
 <20150715.211916.1258342954251964451.davem@davemloft.net>
 <d1e303ece500475b8e422d55f82fbffd@SIXPR30MB031.064d.mgd.msft.net>
 <87fv4mn7v9.fsf@vitty.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "pebolle@tiscali.nl" <pebolle@tiscali.nl>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "stephen@networkplumber.org" <stephen@networkplumber.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>, David Miller <davem@davemloft.net>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87fv4mn7v9.fsf@vitty.brq.redhat.com>
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

> -----Original Message-----
> From: Vitaly Kuznetsov
> Sent: Friday, July 17, 2015 23:04
> To: Dexuan Cui
> Dexuan Cui writes:
> 
> >> From: David Miller
> >> Sent: Thursday, July 16, 2015 12:19
> >>
> >> From: Dexuan Cui
> >> Date: Tue, 14 Jul 2015 03:00:48 -0700
> >>
> >> > +	pr_debug("hvsock_sk_destruct: called\n");
> >>
> >> Debug logging just to state that a function is called is not appropriate,
> >> we have very sophisticated tracing facilities in the kernel that can do
> >> that transparently, and more.
> >>
> >> Please remove this.
> > OK.
> >
> >> > +	if (hvsk->channel) {
> >> > +		pr_debug("hvsock_sk_destruct: calling vmbus_close()\n");
> >>
> >> Likewise, these kinds of debug logs are totally inappropriate.
> > OK, I'll remove all the pr_debug() in the patch.
> >
> 
> I'd suggest we rather use something like net_dbg_ratelimited()
> intead. The driver is new so issues are expected. Some debugging may
> be useful)
> 
>   Vitaly

The net_*ratelimited() functions may lose message if the messages are
printed very frequently, like in hvsock_sendmsg()/hvsock_recvmsg().

I used pr_debug() because I saw it's widely used in net/ipv4/.
Usually CONFIG_DYNAMIC_DEBUG=y, so pr_debug() means 
dynamic_pr_debug(), which won't output anything by default.

Sorry, I'm not sure about the "sophisticated tracing facilities in the
kernel that can do that transparently, and more" mentioned by David.

Anyway, I don't mind  simply removing the pr_debug() usages.
I will send out V3 later today.

Thanks,
-- Dexuan
