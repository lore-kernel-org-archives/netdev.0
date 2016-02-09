From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: RE: [PATCH net-next] hv_netvsc: Increase delay for
 RNDIS_STATUS_NETWORK_CHANGE
Date: Tue, 9 Feb 2016 15:31:34 +0000
Message-ID: <BN1PR0301MB07700DD7E77C7B71C650B37DCAD60@BN1PR0301MB0770.namprd03.prod.outlook.com>
References: <1454458556-10591-1-git-send-email-haiyangz@microsoft.com>
 <20160209.050438.1204672612521151525.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160209.050438.1204672612521151525.davem@davemloft.net>
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
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 9, 2016 5:05 AM
> To: Haiyang Zhang <haiyangz@microsoft.com>
> Cc: netdev@vger.kernel.org; KY Srinivasan <kys@microsoft.com>;
> olaf@aepfle.de; vkuznets@redhat.com; linux-kernel@vger.kernel.org;
> driverdev-devel@linuxdriverproject.org
> Subject: Re: [PATCH net-next] hv_netvsc: Increase delay for
> RNDIS_STATUS_NETWORK_CHANGE
> 
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Tue,  2 Feb 2016 16:15:56 -0800
> 
> > We simulates a link down period for RNDIS_STATUS_NETWORK_CHANGE
> > message to trigger DHCP renew. User daemons may need multiple seconds
> > to trigger the link down event. (e.g. ifplugd: 5sec, network-manager:
> > 4sec.) So update this link down period to 10 sec to properly trigger DHCP
> renew.
> >
> > Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> 
> Two things look really bad about this to me:
> 
> 1) Any value you choose is arbitrary.  If some new network configuration
> daemon
>    is slower, you will have to change this value again.
> 
>    This is _NOT_ sustainable in the long term.
> 
> 2) It is completely unclear to me why this driver needs to delay at all or
>    wait for anything.  I see no other driver having to deal with this issue.
> 
> Until you address both of these points I am not going to apply this patch.

1) I share your concern as well. Is there a universal way to immediately trigger 
DHCP renew of all current and future daemons with a single event from kernel? 
If not, can we put the delay (RNDIS_STATUS_NETWORK_CHANGE only) into a 
tunable variable of this driver?

2) We used to have the call_usermodehelper "/etc/init.d/network restart" to 
trigger DHCP renew. In commit 27a70af3f4, Vitaly has replaced it with the current 
code that updates the link status with at least 2 seconds interval, so that the 
"link_watch infrastructure" can send notification out. link_watch infrastructure 
only sends one notification per second.

Thanks,
- Haiyang
