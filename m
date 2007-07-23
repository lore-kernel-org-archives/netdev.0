From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [GENETLINK]: Question: global lock (genl_mutex) possible refinement?
Date: Mon, 23 Jul 2007 12:29:09 +0200
Message-ID: <20070723102909.GA9285@postel.suug.ch>
References: <46A0B017.4080505@st.com> <46A0B6DE.1080904@trash.net> <46A0BF7F.80001@st.com> <46A0BFFF.5020000@trash.net> <46A0DF91.6000508@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Richard MUSIL <richard.musil@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:56066 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932939AbXGWK2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jul 2007 06:28:49 -0400
Content-Disposition: inline
In-Reply-To: <46A0DF91.6000508@st.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Richard MUSIL <richard.musil@st.com> 2007-07-20 18:15
> Patrick McHardy wrote:
> > Export the lock/unlock/.. functions. You'll also need a new version 
> > similar to __rtnl_unlock.
> 
> Patrick, you might feel, I am not reading your lines, but in fact I do.
> The problem is that I do not feel competent to follow/propose such
> changes. So what I propose here (in included patch) is the least change
> scenario, which I can think of and on which I feel safe.
> 
> If there are some other changes required, as you suggested for example
> exporting lock from genetlink module, I hope authors of genetlink will
> comment on that. Currently, I do not see any reason for that, but this
> could be due to my limited knowledge.

Actually there is no reason to not use separate locks for the
message serialization and the protection of the list of registered
families. There is only one lock simply for the reason that I've
never thought of anybody could think of registering a new genetlink
family while processing a message.

Alternatively you could also postpone the registration of the new
genetlink family to a workqueue.
