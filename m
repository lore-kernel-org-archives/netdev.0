From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: suggestion for routing code improvement
Date: Wed, 10 Apr 2002 13:51:12 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <3CB47B90.B4CF1FAD@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org


Well, we're into a new experimental branch, so I figured the time had come to
bring back an idea that didn't make it in a year ago.

Currently, if you add custom routes and then down the device that the routes are
associated with, the routes are then removed.  This is entirely understandable.

However, when you then up the interface, the routes do not come back up
automatically.  This is the part that I don't agree with.

Addresses, automatic routes, and custom rules either stay in effect or are
brought back up by the system when an interface is downed and then upped.  The
only exception to this is custom routes.

I propose that these custom routes be stored in some fashion, and then be
brought back up when the device is brought back up.  This would make certain
types of link management much simpler.  Custom routes, once added, would stay in
effect until explicitly removed.  As it stands now, any time you down/up a link
you have to then go back and add all the custom routes again.  This can be a
pain in the butt.

So, what do you guys think?  Is this a reasonable thing to do?  I think that it
makes the system nicely symmetrical, as opposed to the asymmetrical handling of
current kernels.

I don't have a really good grasp of what data structures are avialable to us in
the routing code, so could someone with a better understanding of the code
comment as to how hard this would be to implement?

Thanks,


Chris




-- 
Chris Friesen                    | MailStop: 043/33/F10  
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
