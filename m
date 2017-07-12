From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] ip netns: Make sure netns name is sane
Date: Wed, 12 Jul 2017 20:12:53 +0200
Message-ID: <20170712181253.GB16375@orbyte.nwl.cc>
References: <20170710111912.22537-1-phil@nwl.cc>
 <20170712093834.3902c59d@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48197 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750999AbdGLSMy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 14:12:54 -0400
Content-Disposition: inline
In-Reply-To: <20170712093834.3902c59d@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 12, 2017 at 09:38:34AM -0700, Stephen Hemminger wrote:
> On Mon, 10 Jul 2017 13:19:12 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > +static bool is_basename(const char *name)
> > +{
> > +	char *name_dup = strdup(name);
> > +	bool rc = true;
> > +
> > +	if (!name_dup)
> > +		return false;
> > +
> > +	if (strcmp(basename(name_dup), name))
> > +		rc = false;
> > +
> > +	free(name_dup);
> > +	return rc;
> > +}
> 
> Looks like natural place to use strdupa.
> 
> static bool is_basename(const char *name)
> {
> 	return strcmp(basename(strdupa(name), name) == 0;
> }

Good point! Anyway, my patch fails to cover 'ip netns del' command
(apart from the '..' issue), so I'd suggest to instead apply Matteo's
version (Message-ID 20170710120831.9355-1-mcroce@redhat.com).

Thanks, Phil
