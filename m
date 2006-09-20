From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] genetlink custom attribute type
Date: Wed, 20 Sep 2006 08:24:48 +0200
Message-ID: <20060920062448.GG18349@postel.suug.ch>
References: <1158219852.2936.12.camel@ux156> <20060914081409.GB18349@postel.suug.ch> <1158225704.2936.27.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, davem <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:4284 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751041AbWITGY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2006 02:24:28 -0400
To: Johannes Berg <johannes@sipsolutions.net>
Content-Disposition: inline
In-Reply-To: <1158225704.2936.27.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Johannes Berg <johannes@sipsolutions.net> 2006-09-14 11:21
> On Thu, 2006-09-14 at 10:14 +0200, Thomas Graf wrote:
> 
> > Looks good, we have to watch the size of struct nla_policy though.
> > This bumps the size from 4 bytes to 16 bytes on 64bit architectures
> > which might become a problem since we always use ATTR_MAX sized
> > arrays.
> 
> Yes, I'm aware of that, but I couldn't think of a way to handle it well.
> 
> I thought about using a second array containing just the check
> functions, and then (ab)using `len' to index into it but that didn't
> seem clean enough.

I agree, I talked about this with various people and some ideas
came up.

Always use function pointers to define the validation policy, i.e.
there would be nla_validate_u32() etc. The problem with this approach
is that for every string attribute with different length a separate
validation function is required which simply adds to code what it
saved from text. It also makes exporting the policy to userspace
impossible.

Following up on your idea, we could save a bit by using ERR_PTR() to
store both the callback pointer and type/len tuple in the very same
pointer but that gets very ugly.

I think its best to use your patch for now and see where this leads to.
