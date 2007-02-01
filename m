From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Thu, 01 Feb 2007 08:06:24 -0500
Message-ID: <1170335184.3915.8.camel@localhost>
References: <200702010618.48692.simonl@parknet.dk>
	 <45C183EF.2040701@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Simon Lodal <simonl@parknet.dk>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:58034 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422851AbXBANG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 08:06:27 -0500
Received: by an-out-0708.google.com with SMTP id b33so311366ana
        for <netdev@vger.kernel.org>; Thu, 01 Feb 2007 05:06:27 -0800 (PST)
In-Reply-To: <45C183EF.2040701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-01-02 at 07:08 +0100, Patrick McHardy wrote:

> 
> I have a patch for HFSC which introduces dynamic resizing of the
> class hash. 

One thing that has bitten me recently was tests to try and see how far i
can go insert xfrm SAD/SPDs - the resizing of the hashes kept allocing
more and more space until i ran out of memory, then swap took over and
hell broke loose. It would be nice in your approach to keep a
configurable upper bound on how much mem a hash table can chew.

> I have planned to generalize it (similar to tcf_hashinfo)
> and convert HTB and CBQ as well, which as a nice side effect will
> allow to get rid of some duplicated code, like hash walking.
> 

You know what would be really nice is a generic piece of code that would
apply for all sorts of netcode that uses hashes (theres a huge amount of
such code) and then converting over slowly all users to it: All
attributes to such hashes are known, max-size, hash() etc. The
tcf_hashinfo is a good start template for such an effort.

cheers,
jamal

