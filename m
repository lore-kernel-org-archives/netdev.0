From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: sunrpc port allocation and IANA reserved list
Date: Tue, 10 Nov 2009 21:32:00 +0000
Message-ID: <1257888720.2834.30.camel@achroite.uk.solarflarecom.com>
References: <4AF9A63B.6010101@nortel.com>
	 <1257875623.2834.19.camel@achroite.uk.solarflarecom.com>
	 <4AF9B2CF.6050305@nortel.com>
	 <1257884799.3044.7.camel@heimdal.trondhjem.org>
	 <4AF9D5D1.9040501@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	netdev@vger.kernel.org, Linux kernel <linux-kernel@vger.kernel.org>
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758212AbZKJVb7@vger.kernel.org>
In-Reply-To: <4AF9D5D1.9040501@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-10 at 15:06 -0600, Chris Friesen wrote:
> On 11/10/2009 02:26 PM, Trond Myklebust wrote:
> > On Tue, 2009-11-10 at 12:37 -0600, Chris Friesen wrote:
> >> On 11/10/2009 11:53 AM, Ben Hutchings wrote:
> >>> On Tue, 2009-11-10 at 11:43 -0600, Chris Friesen wrote:
> >>
> >>>> Given that a userspace application can be stopped and restarted at any
> >>>> time, and a sunrpc registration can happen at any time, what is the
> >>>> expected mechanism to prevent the kernel from allocating a port for use
> >>>> by sunrpc that reserved or well-known?
> >>>>
> >>>> Apparently Redhat and Debian have distro-specific ways of dealing with
> >>>> this, but is there a standard solution?  Should there be?
> >>>>
> >>>> The current setup seems suboptimal.
> >>>
> >>> I believe both RH and Debian are using the same implementation:
> >>> <http://cyberelk.net/tim/software/portreserve/>.
> >>
> >> That helps with the startup case, but still leaves a possible hole if an
> >> app using a fixed port number is restarted at runtime.  During the
> >> window where nobody is bound to the port, the kernel could randomly
> >> assign it to someone else.
> > 
> > Just use /proc/sys/sunrpc/{max,min}_resvport interface to restrict the
> > range used to a safer one. That's what it is for...

Unless I'm much mistaken, that only affects in-kernel SunRPC users.

> What constitutes a "safer range"?  IANA has ports assigned
> intermittently all the way through the default RPC range.  The largest
> unassigned range is 922-988 (since 921 is used by lwresd).  If someone
> needs more than 66 ports, how are they supposed to handle it?

I'm sure we could afford 128 bytes for a blacklist of privileged ports.
However, the problem is that there is no API for userland to request
'any free privileged port' - it has to just try binding to different
ports until it finds one available.  This means that the kernel can't
tell whether a process is trying to allocate a specifically assigned
port or whether the blacklist should be applied.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
