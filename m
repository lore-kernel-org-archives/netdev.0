From: James Carlson <carlsonj@workingcode.com>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 9 Feb 2006 08:15:23 -0500
Message-ID: <17387.16491.897130.952966@gargle.gargle.HOWL>
References: <20060208222559.GA14543@mipter.zuzino.mipt.ru>
	<17386.27957.822041.83512@gargle.gargle.HOWL>
	<17386.29792.87133.852682@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Al Viro <viro@ftp.linux.org.uk>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: Paul Mackerras's message of 9 February 2006 09:44:48
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul Mackerras writes:
> > And the solution is to treat it as a boolean instead?!  I'm not sure
> > which is more ugly.
> > 
> > Why wouldn't explicit comparison against NULL be the preferred fix?
> 
> I just think this whole "you shouldn't compare a pointer to 0" thing
> is completely silly,

Indeed.

> However, the head penguin seems to have some bee in his bonnet about 0
> not being a pointer value (despite what the C standard says), so
> whatever.  *shrug*

Yeesh.

My point was that if you're going to get bent over something silly
like this, you might as well change it to something explicit, such as
a comparison of two pointers, rather than pretending that either
pointers or integers are in fact booleans.

I realize that it's entirely legal (per the standards) to write:

	if (p)

as it is to write:

	if (p != 0)

and also:

	if (p != NULL)

But if we're actually interested in clarity, rather than passing some
woe-begotten lint-like purity test, only that third form actually says
what the code does.  The other two may well be idiomatic in certain
circles, but they're nowhere near as lucid for those maintaining the
code.

I think that if this patch is "important," then something other than
just clarity is valued.  In that case, just ignore me, and do what you
will.

-- 
James Carlson         42.703N 71.076W         <carlsonj@workingcode.com>
