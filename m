From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] HTB O(1) class lookup
Date: Thu, 01 Feb 2007 07:08:47 +0100
Message-ID: <45C183EF.2040701@trash.net>
References: <200702010618.48692.simonl@parknet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
To: Simon Lodal <simonl@parknet.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47906 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161207AbXBAGIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Feb 2007 01:08:53 -0500
In-Reply-To: <200702010618.48692.simonl@parknet.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simon Lodal wrote:
> This patch changes HTB's class storage from hash+lists to a two-level linear 
> array, so it can do constant time (O(1)) class lookup by classid. It improves 
> scalability for large number of classes.
> 
> Without the patch, ~14k htb classes can starve a Xeon-3.2 at only 15kpps, 
> using most of it's cycles traversing lists in htb_find(). The patch 
> eliminates this problem, and has a measurable impact even with a few hundred 
> classes.
> 
> Previously, scalability could be improved by increasing HTB_HSIZE, modify the 
> hash function, and recompile, but this patch works for everyone without 
> recompile and scales better too.

I agree that the current fixed sized hashes (additionally quite
small by default) are a big problem with many classes, for all of
HTB/HFSC/CBQ. But I think your approach is a bit wasteful, with
unfortunately chosen classids 128 classes are enough to reach the
maximum memory usage of ~512kb (with 4k pages and 8 byte pointers).

I have a patch for HFSC which introduces dynamic resizing of the
class hash. I have planned to generalize it (similar to tcf_hashinfo)
and convert HTB and CBQ as well, which as a nice side effect will
allow to get rid of some duplicated code, like hash walking.

If you give me a few days I'll try to finish and post it.
