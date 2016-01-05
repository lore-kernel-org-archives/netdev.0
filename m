From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V5 5/9] Drivers: hv: vmbus: add APIs to send/recv hvsock
 packets
Date: Tue, 5 Jan 2016 15:53:46 +0000
Message-ID: <9165bc8a50f742c79d9b62d00d68aedd@HKXPR3004MB0088.064d.mgd.msft.net>
References: <1450966481-13208-1-git-send-email-decui@microsoft.com>
 <87mvsk19qx.fsf@vitty.brq.redhat.com>
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
 "stefanha@redhat.com" <stefanha@redhat.com>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "davem@davemloft.net" <davem@davemloft.net>,
 "dan.carpenter@oracle.com" <dan.carpenter@oracle.com>
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <87mvsk19qx.fsf@vitty.brq.redhat.com>
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

> From: Vitaly Kuznetsov [mailto:vkuznets@redhat.com]
> Sent: Tuesday, January 5, 2016 20:39
> ...
> > +/*
> > + * vmbus_sendpacket_hvsock - Send the hvsock payload 'buf' of a length 'len'
> > + */
> > +int vmbus_sendpacket_hvsock(struct vmbus_channel *channel, void *buf,
> u32 len)
> > ...
> > +
> > +	bufferlist[0].iov_base = &desc;
> > +	bufferlist[0].iov_len  = sizeof(struct vmpacket_descriptor);
> > +	bufferlist[1].iov_base = &pipe_hdr;
> > +	bufferlist[1].iov_len  = sizeof(struct vmpipe_proto_header);
> > +	bufferlist[2].iov_base = buf;
> > +	bufferlist[2].iov_len  = len;
> > +	bufferlist[3].iov_base = &aligned_data;
> > +	bufferlist[3].iov_len  = packetlen_aligned - packetlen;
> > +
> > +	ret = hv_ringbuffer_write(&channel->outbound, bufferlist, 4,
> > &signal);
> 
> Using ARRAY_SIZE(bufferlist) instead of 4 would allow us to keep this
> line untouched when we decide to add something (and compiler will
> optimize it to 4 anyway).

Thanks for the suggestion! I'll fix it.

-- Dexuan
