From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RFC] stuff from tcp-2.6 partially merged to upcoming net-2.6.24?
Date: Wed, 8 Aug 2007 16:13:31 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708081529300.23600@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0708071356060.8788@kivilampi-30.cs.helsinki.fi>
 <20070808.035505.110907605.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1219907105-1186576307=:23600"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44747 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755686AbXHHNNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 09:13:32 -0400
In-Reply-To: <20070808.035505.110907605.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0708081605380.23600@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1219907105-1186576307=:23600
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0708081531571.23600@kivilampi-30.cs.helsinki.fi>

On Wed, 8 Aug 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue, 7 Aug 2007 16:19:58 +0300 (EEST)
> 
> > Do you have any suggestion how I should proceed? Or do you perhaps object 
> > such partial merge completely? ...I could try to come up with a cleaned up 
> > patch series which has original and their bug fix parts combined to a 
> > single patch per change (would provide cleaner history and shouldn't be 
> > very hard to do either)...
> 
> Thank you for doing the rebase.  I agree with you that we should
> seperate out as much of the non-rb-tree stuff as possible and put it
> into net-2.6.24

...It would also help a lot in case we at some point of time in the future 
decide to merge rb-tree stuff but then have to back up to have it merged 
in a cleaner state which is easier to revert than with cleanups 
combined... Besides once I get some additional bits done (haven't yet 
dared to do L-bit cascade surgery which will fix timedout loop entry 
bugs and allow dropping of retrans hint counter), long enough mm sit would 
be nice route to rbtree stuff since there it's getting at least bit more
versitile testing that we alone can put to it...

> I'll will try hard to make time to look at your rebase and try to move
> things forward. 

...I case you want to validate them, git-patch-id helps to exclude 
identical changes between before and after allowing you to spend more
time on things that required non-trivial resolution...

> I've been all-consumed by the NAPI work and a driver I've been writing 
> in the background for the past few weeks.

...I can try to help... I suggest that as first step we take all changes 
that do not cause any conflicts (I've already tried cherry-picks), only 
thing I'm not sure whether I should combine change+fix parts or keep 
them as they were in tcp-2.6 (I suggest we combine them but you may 
disagree..?). I can either post them as series or give you them in 
--pretty=oneline format if you want to cherry-pick them yourself (in 
that case having a common tree would help a bit as commit ids would
match as well then)).

However, at least highest_sack inclusion (no space loss as one hint 
counter can be then dropped and allows accurate fackets out which I've 
partially coded already) will need also SACK-block validator. But I
basically have to redo as the validator patch was sacktag reorganization 
based previously (I've already found couple of improvements too to it's
accuracy :-))...


-- 
 i.
---696243703-1219907105-1186576307=:23600--
