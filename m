From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH v3 1/2] netfilter_queue: enable UID/GID socket info
 retrieval
Date: Fri, 20 Dec 2013 16:03:24 +0100
Message-ID: <20131220150324.GB29632@breakpoint.cc>
References: <1387542820-16319-1-git-send-email-valentina.giusti@bmw-carit.de>
 <1387542820-16319-2-git-send-email-valentina.giusti@bmw-carit.de>
 <20131220140959.GA29632@breakpoint.cc>
 <52B45504.20608@bmw-carit.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, jpa@google.com, pablo@netfilter.org,
	daniel.wagner@bmw-carit.de
To: Valentina Giusti <valentina.giusti@bmw-carit.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52B45504.20608@bmw-carit.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valentina Giusti <valentina.giusti@bmw-carit.de> wrote:
> >I think this should be 'return 0'?
> I put return -1 because I think that if userspace has requested to
> receive UID and GID, then it should be dumped only packets that have
> that information available.
> Are you suggesting that it should be otherwise?

Yes, doing that doesn't make sense to me.
And it is inconsitent:
Packets without socket information are queued normally
in your patch, but suddently if its a timewait socket
its an error?

Why would we want timewait packets to NOT be queued?
vs. for example forwarded packets?

Userspace can test for presence of the attributes, i.e.
no NFQA_UID attribute -> no socket present, or lack of uid
information.

If you have a counter-example?
