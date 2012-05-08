From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCH] net: update the usage of
	CHECKSUM_UNNECESSARY
Date: Tue, 8 May 2012 19:20:58 +0100
Message-ID: <1336501258.2749.3.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120319211241.11291.53271.stgit@localhost6.localdomain6>
 <20120508174831.GA27406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: "Michael S. Tsirkin" <mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <20120508174831.GA27406-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.open-fcoe.org/mailman/options/devel>,
 <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-fcoe.org/mailman/listinfo/devel>,
 <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-05-08 at 20:48 +0300, Michael S. Tsirkin wrote:
> On Mon, Mar 19, 2012 at 02:12:41PM -0700, Yi Zou wrote:
> > As suggested by Ben, this adds the clarification on the usage of
> > CHECKSUM_UNNECESSARY on the outgoing patch. Also add the usage
> > description of NETIF_F_FCOE_CRC and CHECKSUM_UNNECESSARY
> > for the kernel FCoE protocol driver.
> > 
> > This is a follow-up to the following:
> > http://patchwork.ozlabs.org/patch/147315/
> > 
> > Signed-off-by: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Cc: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> > Cc: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Cc: www.Open-FCoE.org <devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
> > ---
> > 
> >  include/linux/skbuff.h |    7 +++++++
> >  1 files changed, 7 insertions(+), 0 deletions(-)
> > 
> > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > index 8dc8257..a2b9953 100644
> > --- a/include/linux/skbuff.h
> > +++ b/include/linux/skbuff.h
> > @@ -94,6 +94,13 @@
> >   *			  about CHECKSUM_UNNECESSARY. 8)
> >   *	NETIF_F_IPV6_CSUM about as dumb as the last one but does IPv6 instead.
> >   *
> > + *	UNNECESSARY: device will do per protocol specific csum. Protocol drivers
> > + *	that do not want net to perform the checksum calculation should use
> > + *	this flag in their outgoing skbs.
> > + *	NETIF_F_FCOE_CRC  this indicates the device can do FCoE FC CRC
> > + *			  offload. Correspondingly, the FCoE protocol driver
> > + *			  stack should use CHECKSUM_UNNECESSARY.
> > + *
> >   *	Any questions? No questions, good. 		--ANK
> >   */
> >  
> 
> So just to make sure I understand, you never get
> UNNECESSARY packets on tx unless you declared NETIF_F_FCOE_CRC?
> 
> Maybe the comment says this somehow but could not figure it out.

That's what should happen now.  In future CHECKSUM_UNNECESSARY could be
used on output by other protocols which don't use TCP/IP-style
checksums, but always dependent on the output device supporting the
relevant offload feature.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
