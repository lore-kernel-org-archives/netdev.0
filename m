From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH] ip netns: Make sure netns name is sane
Date: Wed, 12 Jul 2017 14:38:22 +0200
Message-ID: <20170712123822.GU16375@orbyte.nwl.cc>
References: <20170710111912.22537-1-phil@nwl.cc>
 <20170710081702.54cf6c8b@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36293 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756357AbdGLMid (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 08:38:33 -0400
Content-Disposition: inline
In-Reply-To: <20170710081702.54cf6c8b@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 10, 2017 at 08:17:02AM -0700, Stephen Hemminger wrote:
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
> Why not just:
> 
> static bool is_basename(const char *name)
> {
> 	return strchr(name '/') == NULL;
> }

This is not sufficient since it doesn't cover netns names of '..' and
'.', as Matteo correctly pointed out.

Cheers, Phil
