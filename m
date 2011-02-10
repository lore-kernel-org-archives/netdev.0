From: Andrew Morton <akpm@linux-foundation.org>
Subject: netfilter is not a filesystem
Date: Thu, 10 Feb 2011 14:11:19 -0800
Message-ID: <20110210141119.56d789fc.akpm@linux-foundation.org>
References: <bug-28862-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bug-28862-10286@https.bugzilla.kernel.org/>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Feb 2011 21:55:26 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=28862
> 
>            Summary: /proc/net/ip_conntrack: no space left on device
>                     systematically

This is why I'm forever nagging people to not just grab some errno
because its name happens to sound similar to the error you just detected.

Yes, it superficially seems nice and logical for netfilter to use
ENOSPC when it runs out of space.  But when that error code propagates
up to the user, they see "no space left on device" and will then run
"df" and wonder what the hell happened to their computer.

The kernel makes this mistake a *lot*.  EFBIG in the rtc drivers?  Really?
