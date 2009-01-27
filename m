From: Patrick McHardy <kaber@trash.net>
Subject: Re: Possible race condition in conntracking
Date: Tue, 27 Jan 2009 14:48:10 +0100
Message-ID: <497F109A.7080502@trash.net>
References: <20090127075744.GA19875@eric.schwarzvogel.de> <497ED1E1.40304@trash.net> <20090127130604.GA19883@eric.schwarzvogel.de> <497F08C4.90705@trash.net> <20090127132810.GA21498@eric.schwarzvogel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Tobias Klausmann <klausman@schwarzvogel.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090127132810.GA21498@eric.schwarzvogel.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tobias Klausmann wrote:
> So the question remains what to do instead and how to do it. That
> probably is deep Netfilter mojo, so I could only speculate wildly.
> 
>> You should see the insert_failed conntrack counter show this
>> (/proc/net/stat/nf_conntrack).
> 
> We do, as I said in my first mail. Near as I can tell,
> nf_conntrack_confirm() is the only function that ever increases
> that counter, so it's definitely dropped there. As to how one
> could handle it differently, I have to defer to people with more
> Netfilter expertise. No point in "fixing" this by breaking other
> stuff.

Fixing this requires some rather intrusive changes. We need
to perform a lookup on the unconfirmed list when a conntrack
is not found in the hash and use the one we find there, if any.
The entries on that list are not reference counted and there
are a lot of assumptions in the code that an unconfirmed conntrack
is exclusively associated with a single packet. This needs to
be audited and fixed, but it looks quite hard.

