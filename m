From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 2/2] nbd: change a parameter's type to remove a memcpy call
Date: Fri, 20 Jul 2007 09:46:38 +0800
Message-ID: <91b13c310707191846qc981c5bhbbac01502a7c8d95@mail.gmail.com>
References: <11848376711601-git-send-email-crquan@gmail.com>
	 <11848377013773-git-send-email-crquan@gmail.com>
	 <469FA0F9.9090001@steeleye.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Pavel Machek" <pavel@ucw.cz>,
	"Steven Whitehouse" <steve@chygwyn.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	debra <chdebra@gmail.com>
To: "Paul Clements" <paul.clements@steeleye.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:22835 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994AbXGTBqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 21:46:40 -0400
Received: by ug-out-1314.google.com with SMTP id j3so529366ugf
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 18:46:38 -0700 (PDT)
In-Reply-To: <469FA0F9.9090001@steeleye.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/20/07, Paul Clements <paul.clements@steeleye.com> wrote:
> Denis Cheng wrote:
> > this memcpy looks so strange, in fact it's merely a pointer dereference,
> > so I change the parameter's type to refer it more directly,
> > this could make the memcpy not needed anymore.
> >
> > in the function nbd_read_stat where nbd_find_request is only once called,
> > the parameter served should be transformed accordingly.
>
> This is really a matter of preference. The generated code ends up being
> about the same, I think, while your patch makes the call to
> nbd_find_request kind of obtuse. Also, the memcpy's are balanced between
> send_req and find_request, so you can quickly see how the data is being
> transferred (from req into handle, and then back again). Your patch
> makes this less clear, at least to me.
With one explicit memcpy stripped out, I think it's more clear to
nbd_find_request.
In nbd_read_stat, the cast to (struct request **) is not apparent, I
must admit; but I think the best solution is declaring other few
structs to make it clear, it's due to the lack of description of nbd
client and server communication protocol.

BTW, I think the nbd driver needs a clear documentation (its main site
http://nbd.sourceforge.net/ does not give it):

1. When nbd_find_request is needed to call, the 8 byte memory of char
handle[8] field in struct nbd_reply actually stores a pointer (struct
request *), that pointer is received from the network. Since a pointer
is only meaningful to the host, transfering it over the network will
be unreliable, I don't think it's a good design,

-- 
Denis Cheng
Linux Application Developer

"One of my most productive days was throwing away 1000 lines of code."
 - Ken Thompson.
