From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: commit : ppp: add rtnetlink device creation support - breaks
 netcf on my machine.
Date: Thu, 8 Dec 2016 10:54:16 +0100
Message-ID: <20161208095416.uktftlzji5woyzqh@alphalink.fr>
References: <32208f70-4165-e79b-89ee-543eefaf40ef@fnarfbargle.com>
 <20161205175320.mbtswpmdjumfgh7y@alphalink.fr>
 <5d537b7e-97e9-709c-7b3e-61280cc264f8@fnarfbargle.com>
 <20161206230853.ukyg75cyxugdwg4a@alphalink.fr>
 <1481065966.11028.3.camel@redhat.com>
 <1481132622.4116.6.camel@redhat.com>
 <ad3f11b0-6814-4589-5b31-028d889237f0@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Haller <thaller@redhat.com>, Dan Williams <dcbw@redhat.com>,
        netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
        David Miller <davem@davemloft.net>
To: Brad Campbell <lists2009@fnarfbargle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:44873 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbcLHJyU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 04:54:20 -0500
Content-Disposition: inline
In-Reply-To: <ad3f11b0-6814-4589-5b31-028d889237f0@fnarfbargle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 08, 2016 at 10:29:44AM +0800, Brad Campbell wrote:
> On 08/12/16 01:43, Thomas Haller wrote:
> > On Tue, 2016-12-06 at 17:12 -0600, Dan Williams wrote:
> > > 
> > > > libnl1 rejects the IFLA_INFO_DATA attribute because it expects it
> > > > to
> > > > contain a sub-attribute. Since the payload size is zero it doesn't
> > > > match the policy and parsing fails.
> > > > 
> > > > There's no problem with libnl3 because its policy accepts empty
> > > > payloads for NLA_NESTED attributes (see libnl3 commit 4be02ace4826
> > 
> > Hi,
> > 
> > libnl1 is unmaintained these days. I don't think it makes sense to
> > backport that patch. The last upstream release was 3+ years ago, with
> > no upstream development since then.
> > 
> > IMHO netcf should drop libnl-1 support.
> > 
> 
> G'day Thomas,
> 
> I'm not sure anyone was suggesting fixing libnl1, it was more around a
> discussion with regard to a change in the kernel breaking old userspace and
> whether it needs to be fixed in the kernel.
> 
Yes, I could add a sub-attribute in IFLA_INFO_DATA (e.g. the PPP unit).
That'd be enough to make libnl1 happy. But that wouldn't make much
sense if not backported to stable kernel versions. Given that the
netlink message is already properly formatted and that the problem only
appears with an obsolete library, I'm not sure that's worth it.

Proper message parsing is a must, or we'd loose the extensibility
proprety of netlink (which was the fundamental reason for creating it
in the first place). So for now, I prefer to leave the code as is,
unless someone asks me otherwise.

> Personally, now I have a solution to *my* immediate problem (that being any
> kernel 4.7 or later prevented libvirtd starting on my servers because my
> netcf was compiled against libnl1) I can upgrade the relevant userspace
> components to work around the issue.
> 
> Also, now this issue is a number of months old and I appear to be the only
> person reporting it, maybe it's not worth tackling. I would absolutely say
> that netcf needs to drop libnl1 now though as it *is* broken on newer
> kernels under the right circumstances.
> 
> I appreciate the assistance in tracking it down anyway. Thanks guys.
> 
You're welcome. Thanks for your clear and detailed report.

Regards,

Guillaume
