From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [net-next 03/17] i40e: allow various base numbers in debugfs aq
 commands
Date: Mon, 24 Nov 2014 17:26:30 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AD9D22F@fmsmsx115.amr.corp.intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1416635708-4765-5-git-send-email-jeffrey.t.kirsher@intel.com>
 <063D6719AE5E284EB5DD2968C1650D6D1C9FA07E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:62615 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204AbaKXR0e convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 12:26:34 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1C9FA07E@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Laight [mailto:David.Laight@ACULAB.COM]
> Sent: Monday, November 24, 2014 8:51 AM
> To: Kirsher, Jeffrey T; davem@davemloft.net
> Cc: Nelson, Shannon; netdev@vger.kernel.org; nhorman@redhat.com;
> sassmann@redhat.com; jogreene@redhat.com
> Subject: RE: [net-next 03/17] i40e: allow various base numbers in
> debugfs aq commands
> 
> From: Jeff Kirsher
> > From: Shannon Nelson <shannon.nelson@intel.com>
> >
> > Use the 'i' rather than the more restrictive 'x' or 'd' in the aq_cmd
> > arguments.  This makes the user interface much more forgiving and user
> > friendly.
> >
> > Change-ID: I5dcd57b9befc047e06b74cf1152a25a3fa9e1309
> > Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> > b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> > index 3a3c237..16ac3f8 100644
> > --- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> > +++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
> > @@ -1493,7 +1493,7 @@ static ssize_t i40e_dbg_command_write(struct
> file *filp,
> >  		if (!desc)
> >  			goto command_write_done;
> >  		cnt = sscanf(&cmd_buf[11],
> > -			     "%hx %hx %hx %hx %x %x %x %x %x %x",
> > +			     "%hi %hi %hi %hi %i %i %i %i %i %i",
> 
> Isn't that an API change?
> Anything that used to specify "10" will now get 10 instead of 16.
> 
> So if this has been in a release kernel you probably shouldn't change
> it.
> 
> 	David

Thanks, David, for looking through our code.

If this were in any other part of the kernel, I would agree with you.  However, this is in our debugfs module, which is not intended for general use.  Following the original definition, there is no expectation of a stable ABI - of course, as discussed in http://lwn.net/Articles/309298/ this is a bit of a pipe dream, but the concept does remain.  As it is, we have already removed a couple of commands, and will likely remove more in the near future as more features are exposed in ethtool and other more standard tools.

The other mitigating factors in my mind are that (a) this is still a very new device, only been in customer hands for a short time, and (b) this particular command is painfully obtuse.  Probably not many have figured out that it is there or how to use it, and the input specs were inconsistent (note the %hd at the end of the second sscanf()).  This patch gives the UI more consistency with standard UI concepts for the aspect of least-surprise, eg forces express base-16 and base-8 format, and it gets this fix in before others likely have run into it.

sln
