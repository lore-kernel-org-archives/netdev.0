From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v14 net-next 1/1] hv_sock: introduce Hyper-V Sockets
Date: Fri, 8 Jul 2016 07:01:58 +0000
Message-ID: <CO2PR03MB2182CCC9450872E3459C8FD9BF3C0@CO2PR03MB2182.namprd03.prod.outlook.com>
References: <CY1PR03MB21865E21E637F03877784979BF240@CY1PR03MB2186.namprd03.prod.outlook.com>
 <20160707160206.GA5279@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "joe@perches.com" <joe@perches.com>,
 Rolf Neugebauer <rolf.neugebauer@docker.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "davem@davemloft.net" <davem@davemloft.net>
To: Olaf Hering <olaf@aepfle.de>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160707160206.GA5279@aepfle.de>
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

> From: Olaf Hering [mailto:olaf@aepfle.de]
> Sent: Friday, July 8, 2016 0:02
> On Thu, Jun 30, Dexuan Cui wrote:
> 
> > +/* The MTU is 16KB per the host side's design. */
> > +struct hvsock_recv_buf {
> > +	unsigned int data_len;
> > +	unsigned int data_offset;
> > +
> > +	struct vmpipe_proto_header hdr;
> > +	u8 buf[PAGE_SIZE * 4];
> 
> Please use some macro related to the protocol rather than a Linux
> compiletime macro.
OK. I'll fix this.
 
> > +/* We send at most 4KB payload per VMBus packet. */
> > +struct hvsock_send_buf {
> > +	struct vmpipe_proto_header hdr;
> > +	u8 buf[PAGE_SIZE];
> 
> Same here.
OK. I'll fix this.

> > + * Copyright(c) 2016, Microsoft Corporation. All rights reserved.
> 
> Here the BSD license follows. I think its required/desired to also
> include a GPL blurb like it is done in many other files:
> ...
>  * Alternatively, this software may be distributed under the terms of
>  * the GNU General Public License ("GPL") version 2 as published by the
>  * Free Software Foundation.
> ....
> 
> Otherwise the MODULE_LICENSE string might be incorrect.
I'll add the GPL blurb.
 
> > +	/* Hyper-V Sockets requires at least VMBus 4.0 */
> > +	if ((vmbus_proto_version >> 16) < 4) {
> > +		pr_err("failed to load: VMBus 4 or later is required\n");
> 
> I guess this mens WS 2016+, and loading in earlier host versions will
> trigger this path? I think a silent ENODEV is enough.
Yes. 
OK, I'll remove the pr_err().

> 
> > +		return -ENODEV;
> 
> Olaf

I'll post v15 shortly, which will address all the comments from Joe and Olaf.

Thanks,
-- Dexuan
