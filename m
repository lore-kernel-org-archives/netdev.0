From: Gleb Natapov <gleb@cloudius-systems.com>
Subject: Re: [PATCH net-next v3 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Tue, 6 Jan 2015 20:44:14 +0200
Message-ID: <20150106184414.GC29721@cloudius-systems.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
 <CALgkqUojkfTwhsoAnPZdJv-oMg7PMB5m8Q2=k5=QqXKxSJgq7w@mail.gmail.com>
 <20150106065535.GM29889@cloudius-systems.com>
 <54ABBFEB.9010105@cloudius-systems.com>
 <CALgkqUqh4uMxhnTA9yOm2m0Z3tOZ1E2+Z8Y68Kv5HJ6vP=Fk2A@mail.gmail.com>
 <20150106180455.GB29721@cloudius-systems.com>
 <CALgkqUpsw3ZBi600tC5H-8LJKLrOgSAX=0+xU4V=aMAGacEEUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, Avi Kivity <avi@cloudius-systems.com>,
	jeffrey.t.kirsher@intel.com, davem@davemloft.net
To: Greg Rose <gvrose8192@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:63212 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770AbbAFSoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 13:44:18 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so52607wiv.14
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 10:44:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALgkqUpsw3ZBi600tC5H-8LJKLrOgSAX=0+xU4V=aMAGacEEUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2015 at 10:30:59AM -0800, Greg Rose wrote:
> On Tue, Jan 6, 2015 at 10:04 AM, Gleb Natapov <gleb@cloudius-systems.com> wrote:
> > On Tue, Jan 06, 2015 at 08:59:41AM -0800, Greg Rose wrote:
> >> On Tue, Jan 6, 2015 at 2:58 AM, Vlad Zolotarov
> >> <vladz@cloudius-systems.com> wrote:
> >> >
> >> >
> >> > I agree with Gleb here: when we started with just thinking about the idea of
> >> > this patch the possible security issue was the first thing that came into
> >> > our minds.
> >> > But eventually we couldn't come up with any security risk or attack example
> >> > that is exclusively caused by the fact that VF knows the indirection table
> >> > and/or RSS hash key of the PF.
> >> >
> >> > So, Greg, if we have missed anything and your have such an example could you
> >> > share it here, please?
> >>
> >> I don't have any examples and that is not my area of expertise.  But
> >> just because we can't think of a security risk or attack example
> >> doesn't mean there isn't one.
> >>
> > Is RSS hash security feature at all? Against what kind of attack? It
> > looks like some drivers (igb among them) use non random value for the key.
> 
> I don't believe RSS hashing itself is a security feature - I don't
> know that sharing the RSS info with a VF is a security risk.  I'm just
> asking that we preserve default behavior to avoid the possibility.
> 
> >
> >> Just add a policy hook so that the system admin can decide whether
> >> this information should be shared with the VFs and then we're covered
> >> for cases of both known and unknown exploits, risks, etc.
> >>
> > Default off means that it will stay that way for most installations and
> > information will not be available for "cloud" users. It is hard to get
> > proper support on public cloud for less trivial issues than changing
> > host HW configuration.
> 
> Someone in the host is configuring the VF HW to begin with.  Someone
> had to create the VFs in the first place so I presume they could set
> the policy for this feature as well at the same time.  To return to an
> example I provided to Vlad - anti-spoof checking is on by default but
> we allow system admins to turn it off so that other features, such as
> bonding, can be used.  I just want to preserve current behavior while
> allowing the feature you want to add to be available for those who
> want it.
> 
> If Dave and the rest of community feel that there is no risk to these
> patches and that they should be applied then I'll go away and shut up
> about it.  But for now I'm just approaching this from a "better safe
> than sorry" viewpoint.
> 
Thanks Greg for explaining your position clearly on this matter. I CCed
Dave to get his opinion. Vlad is going to work on adding this knob
anyway meanwhile, but we still have a hope that default could be "on".

--
			Gleb.
