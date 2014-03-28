From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net] net: vxlan: fix crash when interface is created with
 no group
Date: Fri, 28 Mar 2014 12:05:56 +0300
Message-ID: <20140328090556.GA9504@zed>
References: <20140326094754.GA19337@zed>
 <OFD0C40ED9.015A05DD-ON87257CA2.003E72F3-87257CA2.003E7300@us.ibm.com>
 <CAF1J0HOd9D1t4hxjMe7Muad71o_pgKQsn3jLxqR5ZFPpj2_Nrw@mail.gmail.com>
 <CAJZOPZL9h0q3iiN7Q2jJWW+uEs0EpNaWqVMqQMyL+-5QGxGWPg@mail.gmail.com>
 <20140325.205324.1845346581147557473.davem@davemloft.net>
 <OF687EFECB.536163E6-ON87257CA7.00513C78-87257CA7.00513C81@us.ibm.com>
 <20140326175018.GA24065@zed>
 <CAHA+R7NY45pgO=5MjXQ_6WOW=32uMsV6vO1T2562VzezZLfUcA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Or Gerlitz <or.gerlitz@gmail.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:56459 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbaC1JGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 05:06:03 -0400
Received: by mail-ee0-f42.google.com with SMTP id d17so3827559eek.1
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 02:06:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7NY45pgO=5MjXQ_6WOW=32uMsV6vO1T2562VzezZLfUcA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 27, 2014 at 01:20:25PM -0700, Cong Wang wrote:
> On Wed, Mar 26, 2014 at 10:50 AM, Mike Rapoport
> <mike.rapoport@ravellosystems.com> wrote:
> >
> > The problem is not only duplication of default destinations, but also
> > the mis^Wuse of default_dst to distinguish whether IPv4 or IPv6 path
> > should be taken because there is no explicit specification of the
> > protocol if neither IFLA_VXLAN_GROUP or IFLA_VXLAN_LOCAL defined at
> > vxlan_newlink. Moreover, if neither of these attributes is present, the
> > custom configuration will always use v4 socket regardles of use of
> > default_dst or fdb entry.
> 
> It should default to IPv4 for compatibility reason.

Yes, of course. The problem is that when IPv4 is not explicitly defined
using GROUP/LOCAL attributes, there are a lot of places that take IPv6
path.
So, what I'm proposing is to explicitly set default_dst family to
AF_INET and override it with AF_INET6 only when IPv6 is explicitly
requested.

--
Sincerely yours,
Mike.
