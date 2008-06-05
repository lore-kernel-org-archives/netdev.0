From: Dave Dillow <dillowda@ornl.gov>
Subject: Re: [ofa-general] Re: [PATCH v3 08/13] QLogic VNIC: sysfs interface
	implementation for the driver
Date: Thu, 5 Jun 2008 01:40:35 -0400
Message-ID: <20080605054035.GA8059@ornl.gov>
References: <20080529095126.9943.84692.stgit@localhost.localdomain>
	<20080529095754.9943.27936.stgit@localhost.localdomain>
	<20080529103003.010c4a08@extreme>
	<20080529174805.GA10903@kroah.com>
	<c8028d330806031125x4181d8e3p9cdaf1f4c79e88c6@mail.gmail.com>
	<1212518703.2217.22.camel@lap75545.ornl.gov>
	<aday75k1pzh.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amar Mudrankit <amar.mudrankit@qlogic.com>, Greg KH <greg@kroah.com>,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>, poornima.kamath@qlogic.com
To: Roland Dreier <rdreier@cisco.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <aday75k1pzh.fsf@cisco.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 04, 2008 at 09:10:26PM -0700, Roland Dreier wrote:
>  > Or so the theory goes. Unfortunately, you need all that information
>  > before you can create the connection. The configfs guys have thought
>  > about that, but not implemented yet:
>  > 
>  > > [Committable Items]
>  > > NOTE: Committable items are currently unimplemented.
> 
> The netconsole code in-tree has a separate "enabled" attribute that
> serves the purpose of "committing" something.  Seems good enough for SRP
> to use to me... the rename to commit idea seems cute but I don't see
> that it buys much beyond this.

But... But... I've got nothing.

I mentioned the enable attribute as a possible way to do it, though it is
counter to the configfs's documented preference.  But it's there, it works
perfectly well, and the configfs guys have had over 2 years to implement
their alternate commit feature.

That said, given that SRP's been using sysfs since it went in, is there
a reason to move to configfs other than it's the new preferred way to do
it? Given the desire to not break ABI's -- and IIRC sysfs was declared to
be under that unbrella -- wouldn't we have to at least carry both
interfaces for a while, assuming we can even get rid of the sysfs one?

Carrying both adds a bit of a interesting twist -- targets added using
the sysfs add-target wouldn't show up under configfs. It may not be a
real problem, but it could be a bit of a surprise to an admin.

I'm not opposed to configfs, but the more I think about it, it doesn't
seem to bring much to the table for the SRP initiator other more code
and data structure size.
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office
