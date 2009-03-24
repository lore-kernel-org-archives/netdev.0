From: "Karl O. Pinc" <kop@meme.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 11:42:57 -0500
Message-ID: <1237912977l.501l.10l@mofo>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from janus.meme.com ([69.17.73.118]:52918 "EHLO smtp.meme.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761349AbZCXROW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 13:14:22 -0400
In-Reply-To: <20090324154617.GA16332@auslistsprd01.us.dell.com> (from
	Matt_Domsch@dell.com on Tue Mar 24 10:46:17 2009)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My thoughts on the subject; from someone who is not
particularly qualified to have opinions.

Reading over your post, I searched for a single sentence describing
the problem you're trying to solve.  What I came up with was
this:

On 03/24/2009 10:46:17 AM, Matt Domsch wrote:

>  Users continue to have to figure out, for each system type
> and
> potentially for each boot, which NIC is connected to which name.  This
> has been the #1 customer complaint about Linux on Dell servers for
> several years.  I'd prefer not to keep it this way.

Perhaps a little magic in the udev rule that creates the
z70_persistent-net-rules file would solve the basic problem.
It could sort the nics by mac address when creating the
names.  It need only run when the z70 file does not exist.
I presume this would produce consistent results in most cases
and it feels technically feasible; although I am not
fully qualified to make that judgment.

Rather that put the onus on udev to make the above
change Dell could just run a little program at first
boot that mungs the z70 file as desired.  (It could then
force a reboot; I forget if this would be needed.)
I imagine Dell boots the boxes once at the factory,
but if not then the user has to suffer with a longer
boot process at first boot.  Because this is driven
by Dell, Dell would know exactly what nic has what
name.  And Dell knows what nics are on the mobo and
what are not, and so can control the mac address sort
order as desired.

The other solution that screams out at me is to ditch
those legacy BIOSes and go to something like LinuxBIOS.
Again, I'm not really qualified, but it sure feels like
there's an answer in this approach.

The other point that struck me was that sometimes, it seems,
users want persistence in the naming of their network devices
and sometimes they want device names based on bus position.

The sucky thing is that symlinks and nics don't mix well
and so it seems impossible to satisfy both the above
requirements at the same time.  This is an area that
IMHO could be better addressed by the Linux community.

Karl <kop@meme.com>
Free Software:  "You don't pay back, you pay forward."
                  -- Robert A. Heinlein
