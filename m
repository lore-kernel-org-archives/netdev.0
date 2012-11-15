From: ANNIE LI <annie.li@oracle.com>
Subject: Re: [Xen-devel] [PATCH 0/4] Implement persistent grant in xen-netfront/netback
Date: Thu, 15 Nov 2012 19:12:35 +0800
Message-ID: <50A4CE23.40804@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com> <20121115074057.GO8912@reaktio.net> <50A4AA06.8080900@oracle.com> <CAOsiSVU+9fkGQhVhnrx=xxUD8hej55XXJGpKGWAxe1USPEhiEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Wei Liu <liuw@liuw.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43263 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423250Ab2KOLMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 06:12:42 -0500
In-Reply-To: <CAOsiSVU+9fkGQhVhnrx=xxUD8hej55XXJGpKGWAxe1USPEhiEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2012-11-15 17:35, Wei Liu wrote:
>
> On Thu, Nov 15, 2012 at 4:38 PM, ANNIE LI <annie.li@oracle.com=20
> <mailto:annie.li@oracle.com>> wrote:
>
>
>
>     On 2012-11-15 15:40, Pasi K=E4rkk=E4inen wrote:
>
>         Hello,
>
>         On Thu, Nov 15, 2012 at 03:03:07PM +0800, Annie Li wrote:
>
>             This patch implements persistent grants for
>             xen-netfront/netback. This
>             mechanism maintains page pools in netback/netfront, these
>             page pools is used to
>             save grant pages which are mapped. This way improve
>             performance which is wasted
>             when doing grant operations.
>
>             Current netback/netfront does map/unmap grant operations
>             frequently when
>             transmitting/receiving packets, and grant operations cost=
s
>             much cpu clock. In
>             this patch, netfront/netback maps grant pages when needed
>             and then saves them
>             into a page pool for future use. All these pages will be
>             unmapped when
>             removing/releasing the net device.
>
>         Do you have performance numbers available already?
>         with/without persistent grants?
>
>     I have some simple netperf/netserver test result with/without
>     persistent grants,
>
>     Following is result of with persistent grant patch,
>
>     Guests, Sum,      Avg,     Min,     Max
>      1,  15106.4,  15106.4, 15106.36, 15106.36
>      2,  13052.7,  6526.34,  6261.81,  6790.86
>      3,  12675.1,  6337.53,  6220.24,  6454.83
>      4,  13194,  6596.98,  6274.70,  6919.25
>
>
>     Following are result of without persistent patch
>
>     Guests, Sum,     Avg,    Min,        Max
>      1,  10864.1,  10864.1, 10864.10, 10864.10
>      2,  10898.5,  5449.24,  4862.08,  6036.40
>      3,  10734.5,  5367.26,  5261.43,  5473.08
>      4,  10924,    5461.99,  5314.84,  5609.14
>
>
>
> Interesting results. Have you tested how good it is on a 10G nic, i.e=
=2E=20
> guest sending packets
> through physical network to another host.
Not yet.

Thanks
Annie
>
>
> Wei.
>
>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
