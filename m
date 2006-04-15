From: "Hisham Kotry" <hkotry@gmail.com>
Subject: skb diet
Date: Sat, 15 Apr 2006 04:17:12 -0700
Message-ID: <baebb9a00604150417h1ffb3f97g102253dca0b3a53e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from pproxy.gmail.com ([64.233.166.176]:3184 "EHLO pproxy.gmail.com")
	by vger.kernel.org with ESMTP id S932487AbWDOLRN convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Apr 2006 07:17:13 -0400
Received: by pproxy.gmail.com with SMTP id i49so269646pye
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2006 04:17:12 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I just read David S. Miller's skb redundancy page and in it he seems to suggest
taking an approach similar to that of BSD's mbufs to reduce the skb's
size. I was going to do some janitor work on the network stack and I
thought that maybe I could start by adding a tag list to the skb
similar to BSD's mbuf tags and change the code to store its private
variables in tags rather than in skb->cb. That should save 40 bytes
per skb and maybe later the tc and nf related variables could go in
tags too. The transition shouldn't be hard for the most part, many
users of skb->cb use macros like FRAG_CB(skb) so I could redefine
those macros to search the tag-list for the appropriate tag and return
its contents. Is this approach acceptable or is there a consensus on
another approach?
