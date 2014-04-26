From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/1]  hyperv: Properly handle checksum offload
Date: Fri, 25 Apr 2014 18:15:27 -0700
Message-ID: <1398474927.29914.100.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1398451514-25593-1-git-send-email-kys@microsoft.com>
 <20140425174322.589ed9f1@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, netdev@vger.kernel.org, jasowang@redhat.com,
 linux-kernel@vger.kernel.org, stable@kernel.org, apw@canonical.com,
 devel@linuxdriverproject.org, davem@davemloft.net
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140425174322.589ed9f1@samsung-9>
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

On Fri, 2014-04-25 at 17:43 -0700, Stephen Hemminger wrote:
> On Fri, 25 Apr 2014 11:45:14 -0700
> "K. Y. Srinivasan" <kys@microsoft.com> wrote:
> 
> > @@ -474,6 +477,9 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
> >  	csum_info = (struct ndis_tcp_ip_checksum_info *)((void *)ppi +
> >  			ppi->ppi_offset);
> >  
> > +	ip_hdr(skb)->check = 0;
> > +	csum_info->transmit.ip_header_checksum = 1;
> > +
> >  	if (net_trans_info & (INFO_IPV4 << 16))
> >  		csum_info->transmit.is_ipv4 = 1;
> >  	else
> 
> Linux doesn't need or want IP checksum offload.
> It will not have any performance gain.


BTW, was this patch even tested with IPv6 packets ???
