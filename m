From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: [PATCH 03/12] Prevent renaming interfaces to empty string.
Date: Fri, 12 Oct 2007 19:45:54 +0200
Message-ID: <1192211154.4733.67.camel@localhost.localdomain>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
	 <1192179407-22461-2-git-send-email-andreas@fatal.se>
	 <1192179407-22461-3-git-send-email-andreas@fatal.se>
	 <20071012100743.0c1a11f8@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexander Wirt <formorer@debian.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:55589 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758552AbXJLRqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 13:46:35 -0400
In-Reply-To: <20071012100743.0c1a11f8@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On fre, 2007-10-12 at 10:07 -0700, Stephen Hemminger wrote:

> >  	if (newname && strcmp(dev, newname)) {
> > +		if (strlen(newname) == 0) {
> > +		    printf("\"\" is not valid device identifier\n");
> > +		    return -1;
> > +		}
> >  		if (do_changename(dev, newname) < 0)
> >  			return -1;
> >  		dev = newname;
> 
> The kernel should already be preventing this?

Looks like something prevents the interface to end up with no name, but
there's no error message...

./ip/ip is the "vanilla" and /sbin/ip is debians version.

$ sudo ./ip/ip link set skif name ""
$ echo $?
0
$ sudo /sbin/ip link set skif name ""
"" is not valid device identifier
$ echo $?
255

Reporting the error is probably the preferred behaviour (and return code
set to error is most likely helpful for scripts).


-- 
Regards,
Andreas Henriksson

