From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH net-next 01/10] hv_netvsc: Resize some of the variables in
 hv_netvsc_packet
Date: Tue, 24 Nov 2015 16:29:24 +0000
Message-ID: <BLUPR0301MB1651ADFFF97BDAF3F5753829A0060@BLUPR0301MB1651.namprd03.prod.outlook.com>
References: <1448321324-21318-1-git-send-email-kys@microsoft.com>
 <1448321346-21357-1-git-send-email-kys@microsoft.com>
 <87ziy3lr5f.fsf@vitty.brq.redhat.com>
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
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87ziy3lr5f.fsf@vitty.brq.redhat.com>
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
> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Tuesday, November 24, 2015 12:48 AM
> To: KY Srinivasan <kys@microsoft.com>
> Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: Re: [PATCH net-next 01/10] hv_netvsc: Resize some of the variables
> in hv_netvsc_packet
> 
> "K. Y. Srinivasan" <kys@microsoft.com> writes:
> 
> > As part of reducing the size of the hv_netvsc_packet, resize some of the
> > variables based on their usage.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> > ---
> >  drivers/net/hyperv/hyperv_net.h |   14 +++++++-------
> >  1 files changed, 7 insertions(+), 7 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> b/drivers/net/hyperv/hyperv_net.h
> > index 5fa98f5..972e562 100644
> > --- a/drivers/net/hyperv/hyperv_net.h
> > +++ b/drivers/net/hyperv/hyperv_net.h
> > @@ -127,11 +127,11 @@ struct ndis_tcp_ip_checksum_info;
> >   */
> >  struct hv_netvsc_packet {
> >  	/* Bookkeeping stuff */
> > -	u32 status;
> > +	u8 status;
> >
> > -	bool is_data_pkt;
> > -	bool xmit_more; /* from skb */
> > -	bool cp_partial; /* partial copy into send buffer */
> > +	u8 is_data_pkt;
> > +	u8 xmit_more; /* from skb */
> > +	u8 cp_partial; /* partial copy into send buffer */
> 
> These are flags so we can make them bitfields and save even more space.

I am not done with restructuring this structure yet. Once I get this to the bare minimum
I will look at using bitfields. 

K. Y
> 
> >
> >  	u16 vlan_tci;
> >
> > @@ -147,13 +147,13 @@ struct hv_netvsc_packet {
> >  	/* This points to the memory after page_buf */
> >  	struct rndis_message *rndis_msg;
> >
> > -	u32 rmsg_size; /* RNDIS header and PPI size */
> > -	u32 rmsg_pgcnt; /* page count of RNDIS header and PPI */
> > +	u8 rmsg_size; /* RNDIS header and PPI size */
> > +	u8 rmsg_pgcnt; /* page count of RNDIS header and PPI */
> >
> >  	u32 total_data_buflen;
> >  	/* Points to the send/receive buffer where the ethernet frame is */
> >  	void *data;
> > -	u32 page_buf_cnt;
> > +	u8 page_buf_cnt;
> >  	struct hv_page_buffer *page_buf;
> >  };
> 
> --
>   Vitaly
