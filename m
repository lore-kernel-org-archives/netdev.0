From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC] stuff from tcp-2.6 partially merged to upcoming net-2.6.24?
Date: Tue, 7 Aug 2007 16:19:58 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708071356060.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34756 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761484AbXHGNUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 09:20:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

...Noticed you were planning to open net-2.6.24 tree... IMHO, part of the 
stuff in tcp-2.6 could be merged to 2.6.24. I suggest that most of the 
stuff which is not directly related to the rbtree, new lost marker, nor
sacktag reorganization are taken. Some of those things are very trivial
to take as they do not introduce have any conflicts. Besides that there 
are some stuff that would need some work if takes as they are built on 
top of stuff that will remain only in tcp-2.6 (includes left_out removal 
and IsReno/Fack conversion)... But if it's ok, I could try to come up with 
a solution even to them... Perhaps do this in two (or more) stages by 
first taking the trivial ones...

I tried rebasing tcp-2.6 (there's some not yet submitted work on top of 
it too) to top of be1b685fe6c9928848b26b568eaa86ba8ce0046c, result is 
here:
  http://www.cs.helsinki.fi/u/ijjarvin/tcp-rebase/{before,after}
...There was at least one gotcha (sacktag's flag reset position change
when sacktag_state is created). But all in all, conflicts weren't that 
hard to resolve... One may resolve some things differently than I did,
so YMMV if you want to try that yourself... :-) ...I also diffed
all.patch'es to see if there was some undesired side-effect from diff 
but didn't find any. Currently only compile tested.

Do you have any suggestion how I should proceed? Or do you perhaps object 
such partial merge completely? ...I could try to come up with a cleaned up 
patch series which has original and their bug fix parts combined to a 
single patch per change (would provide cleaner history and shouldn't be 
very hard to do either)...

-- 
 i.
