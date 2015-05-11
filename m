From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH V4 net-next 1/1] hv_netvsc: Use the xmit_more skb flag to
 optimize signaling the host
Date: Mon, 11 May 2015 02:48:59 +0000
Message-ID: <BY2PR0301MB07110581F43CA51C45883272A0DB0@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1430951345-7767-1-git-send-email-kys@microsoft.com>
 <20150510.175057.1320510115648828229.davem@davemloft.net>
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
In-Reply-To: <20150510.175057.1320510115648828229.davem@davemloft.net>
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
> Sent: Sunday, May 10, 2015 2:51 PM
> To: KY Srinivasan
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; olaf@aepfle.de; apw@canonical.com;
> jasowang@redhat.com
> Subject: Re: [PATCH V4 net-next 1/1] hv_netvsc: Use the xmit_more skb flag
> to optimize signaling the host
> 
> From: "K. Y. Srinivasan" <kys@microsoft.com>
> Date: Wed,  6 May 2015 15:29:05 -0700
> 
> > -		ret = vmbus_sendpacket_pagebuffer(out_channel,
> > -						  pgbuf,
> > -						  packet->page_buf_cnt,
> > -						  &nvmsg,
> > -						  sizeof(struct
> nvsp_message),
> > -						  req_id);
> > +		ret = vmbus_sendpacket_pagebuffer_ctl(out_channel,
> > +						      pgbuf,
> > +						      packet->page_buf_cnt,
> > +						      &nvmsg,
> > +						      sizeof(struct
> > +							     nvsp_message),
> > +						      req_id,
> > +						      vmbus_flags,
> > +						      !packet->xmit_more);
> >  	} else {
> > -		ret = vmbus_sendpacket(
> > +		ret = vmbus_sendpacket_ctl(
> >  				out_channel, &nvmsg,
> >  				sizeof(struct nvsp_message),
> >  				req_id,
> >  				VM_PKT_DATA_INBAND,
> > -
> 	VMBUS_DATA_PACKET_FLAG_COMPLETION_REQUESTED);
> > +				vmbus_flags, !packet->xmit_more);
> 
> Just as you did for the vmbus_sendpacket_pagebuffer_ctl() call above,
> you'll need to reindent the arguments for the vmbus_sendpacket_ctl()
> call since the openning parenthesis is now at a different column.

Done.

Regards,

K. Y
> 
> Thanks.
