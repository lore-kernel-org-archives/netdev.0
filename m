From: Andi Kleen <ak@suse.de>
Subject: Re: skb diet
Date: Sat, 15 Apr 2006 21:22:01 +0200
Message-ID: <200604152122.01914.ak@suse.de>
References: <baebb9a00604150417h1ffb3f97g102253dca0b3a53e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:2021 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S1751268AbWDOTWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2006 15:22:14 -0400
To: "Hisham Kotry" <hkotry@gmail.com>
In-Reply-To: <baebb9a00604150417h1ffb3f97g102253dca0b3a53e@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 15 April 2006 13:17, Hisham Kotry wrote:
> I just read David S. Miller's skb redundancy page and in it he seems to suggest
> taking an approach similar to that of BSD's mbufs to reduce the skb's
> size. I was going to do some janitor work on the network stack and I
> thought that maybe I could start by adding a tag list to the skb
> similar to BSD's mbuf tags and change the code to store its private
> variables in tags rather than in skb->cb. That should save 40 bytes
> per skb and maybe later the tc and nf related variables could go in
> tags too. The transition shouldn't be hard for the most part, many
> users of skb->cb use macros like FRAG_CB(skb) so I could redefine
> those macros to search the tag-list for the appropriate tag and return
> its contents. Is this approach acceptable or is there a consensus on
> another approach?

Where would that tag list be stored if you want to remove the 
40 bytes of ->cb?

In general I don't think it will help much even if you find
a magic way to store it without using memory @) because
->cb is already private to each layer, so it's only the single 40 bytes
which is reused as needed.

You seem to think they accumulate which is not the case.

Linux 2.0 did something like this, but that was removed for good 
reasons. Now TCP always clones skbs before sending it out.

And optimizing for uncommon cases (not TCP) doesn't seem too useful.

-Andi
