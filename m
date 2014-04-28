From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V1 net-next 1/1] hyperv: Properly handle checksum offload
Date: Mon, 28 Apr 2014 18:31:56 +0000
Message-ID: <6a4748198dba455588493c4e95845330@BY2PR03MB299.namprd03.prod.outlook.com>
References: <1398484523-27596-1-git-send-email-kys@microsoft.com>
 <20140428.132347.778081265367223580.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "stable@kernel.org" <stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140428.132347.778081265367223580.davem@davemloft.net>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, April 28, 2014 10:24 AM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com; stable@kernel.org
> Subject: Re: [PATCH V1 net-next 1/1] hyperv: Properly handle checksum
> offload
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Fri, 25 Apr 2014 20:55:23 -0700
> 
> > @@ -467,6 +467,9 @@ static int netvsc_start_xmit(struct sk_buff *skb,
> struct net_device *net)
> >  	if (skb_is_gso(skb))
> >  		goto do_lso;
> >
> > +	if (skb->ip_summed != CHECKSUM_PARTIAL)
> > +		goto do_send;
> > +
> 
> There are many possible values of ip_summed, why would you go to
> do_send if for example it was set to CHECKSUM_COMPLETE?
> 
> I think you are just rushing this change, take your time and implement the fix
> properly.
> 
> For example, if you only expect two possible values here
> (CHECKSUM_PARTIAL and something else), design your test so that it only
> allows those two values and therefore you'll be documenting this invariant.

David,

I based this check on the check I see in tcp_v4_send_check() (and tcp_v6_send_check).
Looking at the code some more, it looks like if ip_summed is set to  CHECKSUM_NONE, the
software has computed the checksum and we can bypass the code for offloading the checksum.

Regards,

K. Y
