From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 1/1] Drivers: net-next: hyperv: Adjust the size of sendbuf
 region to support ws2008r2
Date: Wed, 6 Aug 2014 17:25:11 +0000
Message-ID: <17897053acd444eca0c73b08961e5f80@BY2PR0301MB0711.namprd03.prod.outlook.com>
References: <1407348660-6844-1-git-send-email-kys@microsoft.com>
 <A70AC0C1B7E7FD478A6BF19705461AA011098B@IMBER.smb.curriegrad2004.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Jeff Leung <jleung@v10networks.ca>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <A70AC0C1B7E7FD478A6BF19705461AA011098B@IMBER.smb.curriegrad2004.ca>
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
> From: Jeff Leung [mailto:jleung@v10networks.ca]
> Sent: Wednesday, August 6, 2014 10:19 AM
> To: KY Srinivasan; davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: RE: [PATCH 1/1] Drivers: net-next: hyperv: Adjust the size of
> sendbuf region to support ws2008r2
> 
> > WS2008R2 is a supported platform and it turns out that the maximum
> sendbuf
> > size that ws2008R2 can support is only 15MB. Make the necessary
> > adjustment.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > ---
> >  drivers/net/hyperv/hyperv_net.h |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/hyperv/hyperv_net.h
> b/drivers/net/hyperv/hyperv_net.h
> > index 40ba1ef..459b823 100644
> > --- a/drivers/net/hyperv/hyperv_net.h
> > +++ b/drivers/net/hyperv/hyperv_net.h
> > @@ -584,7 +584,7 @@ struct nvsp_message {
> >
> >  #define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*16)
> 	/* 16MB
> > */
> >  #define NETVSC_RECEIVE_BUFFER_SIZE_LEGACY	(1024*1024*15)  /*
> 15MB
> */
> > -#define NETVSC_SEND_BUFFER_SIZE			(1024 * 1024 *
> 16)   /* 16MB */
> > +#define NETVSC_SEND_BUFFER_SIZE			(1024 * 1024 *
> 15)   /* 15MB */
> 
> Would it be possible to use separate ifdefs depending on the version of the
> Hyper-V host so we can maintain the 16MB buffer for hosts that support it
> and leave it at 15MB for hosts that don't support that large of a buffer?

We could certainly do that. For the receive buffers, we actually size them based on the host.
For sendbuf, the performance difference between 15M and 16M is not measurable. I had initially
chosen 16MB to match with the receive buffer size. Since there was no perf advantage, I chose to
set the sendbuf size to 15M to work on all supported hosts.

K. Y 
> 
> >  #define NETVSC_INVALID_INDEX			-1
> >
> >
> > --
> > 1.7.4.1
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe
> linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org More majordomo
> info
> > at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
