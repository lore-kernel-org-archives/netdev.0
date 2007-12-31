From: James Morris <jmorris@namei.org>
Subject: Re: 2.6.24-rc6-mm1 - git-lblnet.patch and networking horkage
Date: Tue, 1 Jan 2008 08:46:09 +1100 (EST)
Message-ID: <Xine.LNX.4.64.0801010841060.25768@us.intercode.com.au>
References: <3281504256.5618888@mail.hp.com> <Xine.LNX.4.64.0712270848260.19279@us.intercode.com.au>
 <200712311213.32515.paul.moore@hp.com> <200712311506.15230.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Valdis.Kletnieks@vt.edu, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, sds@tycho.nsa.gov,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753673AbXLaVqm@vger.kernel.org>
In-Reply-To: <200712311506.15230.paul.moore@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Dec 2007, Paul Moore wrote:

> I'm pretty certain this is an uninitialized value problem now and not a 
> use-after-free issue.  The invalid/garbage ->iif value seems to only happen 
> on packets that are generated locally and sent back into the stack for local 
> consumption, e.g. loopback.  These local packets also need to have been 
> cloned at some point, either on the output or input path.

I think we need to find out exactly what's happening, first.

> The problem appears to be a skb_clone() function which does not clear the skb 
> structure properly and fails to copy the ->iif value from the original skb to 
> the cloned skb.  From what I can tell, there are two possible solutions to 
> this problem:
> 
>  1. Clear all of the cloned skb fields in skb_clone() via memset()

Sounds like it's not going to fly for performance reasons in any case.

>  2. Copy the ->iif field in __copy_skb_header()

Seems valid.


- James
-- 
James Morris
<jmorris@namei.org>
