From: KY Srinivasan <kys@microsoft.com>
Subject: RE: [PATCH 09/17] Tools: hv: Represent the ipv6 mask using CIDR
 notation
Date: Tue, 24 Jul 2012 16:53:50 +0000
Message-ID: <426367E2313C2449837CD2DE46E7EAF9236A7733@SN2PRD0310MB382.namprd03.prod.outlook.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-9-git-send-email-kys@microsoft.com>
 <20120724160108.GA13749@x1.osrc.amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "virtualization@lists.osdl.org" <virtualization@lists.osdl.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "apw@canonical.com" <apw@canonical.com>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "ben@decadent.org.uk" <ben@decadent.org.uk>
To: Borislav Petkov <bp@alien8.de>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <20120724160108.GA13749@x1.osrc.amd.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
 <mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Borislav Petkov [mailto:bp@alien8.de]
> Sent: Tuesday, July 24, 2012 12:01 PM
> To: KY Srinivasan
> Cc: gregkh@linuxfoundation.org; linux-kernel@vger.kernel.org;
> devel@linuxdriverproject.org; virtualization@lists.osdl.org; olaf@aepfle.de;
> apw@canonical.com; netdev@vger.kernel.org; ben@decadent.org.uk
> Subject: Re: [PATCH 09/17] Tools: hv: Represent the ipv6 mask using CIDR
> notation
> 
> On Tue, Jul 24, 2012 at 09:01:33AM -0700, K. Y. Srinivasan wrote:
> > Transform ipv6 subnet information to CIDR notation.
> >
> > Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> > Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> > ---
> >  tools/hv/hv_kvp_daemon.c |   45
> +++++++++++++++++++++++++++++++++++----------
> >  1 files changed, 35 insertions(+), 10 deletions(-)
> >
> > diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
> > index 2c24ebf..007e698 100644
> > --- a/tools/hv/hv_kvp_daemon.c
> > +++ b/tools/hv/hv_kvp_daemon.c
> > @@ -491,6 +491,15 @@ done:
> >  	return;
> >  }
> >
> > +static unsigned int hweight32(unsigned int *w)
> > +{
> > +	unsigned int res = *w - ((*w >> 1) & 0x55555555);
> > +	res = (res & 0x33333333) + ((res >> 2) & 0x33333333);
> > +	res = (res + (res >> 4)) & 0x0F0F0F0F;
> > +	res = res + (res >> 8);
> > +	return (res + (res >> 16)) & 0x000000FF;
> > +}
> 
> What's wrong with the hweight32 version we have already in
> <include/asm-generic/bitops/const_hweight.h> which you can include by
> simply by including <asm-generic/bitops.h>?

Boris,

This code is a user-level daemon that will be compiled outside of the kernel.
I did not want to include Kernel header files for this one function and deal with
all the dependencies that will have to be dealt with.

Regards,

K. Y
