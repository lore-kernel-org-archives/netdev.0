From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Tue, 28 Apr 2015 03:23:52 +0000
Message-ID: <BY2PR0301MB07118B0C158FFED152658DA6A0E80@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1430183690-24198-1-git-send-email-kys@microsoft.com>
 <20150427.225709.1737864122610182544.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20150427.225709.1737864122610182544.davem@davemloft.net>
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
> Sent: Monday, April 27, 2015 7:57 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Mon, 27 Apr 2015 18:14:50 -0700
> 
> > Commit commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated
> memory
> > allocation in the packet send path. This commit introduced a bug since it
> > did not account for the case if the skb was cloned. Fix this bug by
> > using the pre-reserved head room only if the skb is not cloned.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> 
> We have generic infrastructure to do this, please try instead:
> 
> 	err = skb_cow_head(skb, pkt_sz);
> 
> this will take care of everything for you and you can get rid
> of all of this dynamic memory allocation etc. in this code
> path.

Thanks David; I will resubmit this patch.

Regards,

K. Y
