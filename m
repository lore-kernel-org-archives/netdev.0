From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH 1/5]net: PPP buffer too small for higher speed
 connections
Date: Tue, 17 Nov 2009 12:35:42 -0800
Message-ID: <1258490142.4447.19.camel@localhost.localdomain>
References: <fb8cc3511cffa.1cffafb8cc351@huawei.com>
	 <20091117172102.GH15159@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: fangxiaozhi 00110321 <huananhu@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	william.allen.simpson@gmail.com, jarkao2@gmail.com
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752566AbZKQUfu@vger.kernel.org>
In-Reply-To: <20091117172102.GH15159@caffeine.csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-17 at 12:21 -0500, Lennart Sorensen wrote:
> On Tue, Nov 17, 2009 at 07:59:05PM +0800, fangxiaozhi 00110321 wrote:
> > From: fangxiaozhi <huananhu@huawei.com>
> > 1. This patch is based on the kernel of 2.6.32-rc7 
> > 2. In this patch, we enlarge the out buffer size to optimize the upload speed for the ppp connection. Then it can support the upload of HSUPA data cards.
> > Signed-off-by: fangxiaozhi <huananhu@huawei.com>
> > -----------------------------------------------------------------------------------------
> > --- a/drivers/net/ppp_async.c	2009-10-12 05:43:56.000000000 +0800
> > +++ b/drivers/net/ppp_async.c	2009-10-15 16:29:56.000000000 +0800
> > @@ -36,7 +36,7 @@
> >  
> >  #define PPP_VERSION	"2.4.2"
> >  
> > -#define OBUFSIZE	256
> > +#define OBUFSIZE	4096
> >  
> >  /* Structure for storing local state. */
> >  struct asyncppp {
> 
> I don't know what an HSUPA connection is, so what kind of speed is that?

(Google and Wikipedia know everything and are only a click away...)

High-Speed Uplink Packet Access is a enhancement for around 5.7Mbps
uplinks on mobile broadband networks based on GSM/UMTS standards.

In the end, what all the mobile manufacturers like Huawei should already
be doing is converting their devices to use an AT-based control port and
a netdev-based data port like Option (hso) and Ericsson (cdc-acm and
cdc-ether) already have.  Then we don't need to do the useless PPP
session between the host and the card.  With GSM/UMTS/HSPA, PPP never
goes over the air, it's purely between the card and the host.  And thus
is pointless and a netdev-type architecture would work a lot better.

Dan

> I am just wondering if this would affect ppp on other connections that
> are async (in a positive manner that is).
> 
