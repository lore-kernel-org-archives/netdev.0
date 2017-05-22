From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH 2/2] Add missing <sys/types.h> include
Date: Mon, 22 May 2017 23:09:23 +0300
Message-ID: <20170522200923.6kn25ulx5mtrv6gi@tarshish>
References: <8afdd8babb9e82bcfde78e851b24b698436a6f9f.1495459674.git.baruch@tkos.co.il>
 <5cdba9c8dc972d25219517ade6129faf73f459b3.1495459674.git.baruch@tkos.co.il>
 <20170522102442.51d36c39@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from guitar.tcltek.co.il ([192.115.133.116]:41591 "EHLO
        mx.tkos.co.il" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1760952AbdEVUJ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 May 2017 16:09:28 -0400
Content-Disposition: inline
In-Reply-To: <20170522102442.51d36c39@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Mon, May 22, 2017 at 10:24:42AM -0700, Stephen Hemminger wrote:
> On Mon, 22 May 2017 16:27:54 +0300
> Baruch Siach <baruch@tkos.co.il> wrote:
> 
> > From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > 
> > The u_intXX_t types are defined in <sys/types.h>, so it should be
> > included before using those types. Otherwise, with certain C
> > libraries, the build fails with:
> > 
> > In file included from ../include/iptables.h:4:0,
> >                  from m_ipt.c:18:
> > ../include/iptables_common.h:47:16: error: unknown type name ‘u_int32_t’
> >  #define __le32 u_int32_t
> > 
> > Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> > Signed-off-by: Baruch Siach <baruch@tkos.co.il>
> > ---
> >  include/iptables_common.h | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/include/iptables_common.h b/include/iptables_common.h
> > index 9099667ffa6d..2c27a4b61fcd 100644
> > --- a/include/iptables_common.h
> > +++ b/include/iptables_common.h
> > @@ -43,6 +43,8 @@ extern char *lib_dir;
> >    extern void init_extensions(void);
> >  #endif
> >  
> > +#include <sys/types.h>
> > +
> >  #define __be32	u_int32_t
> >  #define __le32	u_int32_t
> >  #define __be16	u_int16_t
> 
> This include file comes from netfilter, so not going to change it in iproute2 repo.

It turns out that this headers is unused since commit 5cd1adba79d33644 (Update 
to current iptables headers). So this patch is no longer needed.

iptables dropped this file in commit a3732db1280 (Moves all declarations in 
iptables_common.h to xtables.h).

baruch

-- 
     http://baruch.siach.name/blog/                  ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.52.368.4656, http://www.tkos.co.il -
