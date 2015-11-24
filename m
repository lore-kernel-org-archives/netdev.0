From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 08/10] hv_netvsc: Don't ask for additional head
 room in the skb
Date: Tue, 24 Nov 2015 16:39:51 +0000
Message-ID: <BLUPR0301MB1651609A4BBA4B1FC2DA44FEA0060@BLUPR0301MB1651.namprd03.prod.outlook.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-8-git-send-email-kys@microsoft.com>
 <20151124085532.GA1740@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Florian Westphal <fw@strlen.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20151124085532.GA1740@breakpoint.cc>
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
> From: Florian Westphal [mailto:fw@strlen.de]
> Sent: Tuesday, November 24, 2015 12:56 AM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH net-next 08/10] hv_netvsc: Don't ask for additional head
> room in the skb
> 
> K. Y. Srinivasan <kys@microsoft.com> wrote:
> > The rndis header is 116 bytes big and can be placed in the default
> > head room that will be available in the skb. Since the netvsc packet
> > is less than 48 bytes, we can use the skb control buffer
> > for the netvsc packet. With these changes we don't need to
> > ask for additional head room.
> 
> Minor nit: could you add a BUILD_BUG_ON test for this?  Something like
> 
> BUILD_BUG_ON(sizeof(struct hv_netvsc_packet) > FIELD_SIZEOF(struct
> sk_buff, cb));

Good point; will add this check.

Thanks,

K. Y
