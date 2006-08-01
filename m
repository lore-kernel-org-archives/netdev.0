From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: Linux TCP in the presence of delays or drops...
Date: Tue, 1 Aug 2006 11:23:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0608011041090.3911@kivilampi-30.cs.helsinki.fi>
References: <44CD0D58.7050207@kom.aau.dk> <44CE42A8.7090305@kom.aau.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:26085 "EHLO
	mail.cs.helsinki.fi") by vger.kernel.org with ESMTP
	id S1750724AbWHAIXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 04:23:55 -0400
To: Oumer Teyeb <oumer@kom.aau.dk>
In-Reply-To: <44CE42A8.7090305@kom.aau.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Jul 2006, Oumer Teyeb wrote:

> -If multiple timeouts occur for one packet then even if we are using the
> timestamp option or FRTO TCP linux is not able to detect spurious
> retransmissions... and TCP linux is able to detect spurious retransmissions
> only for a single timeout for one packet or fast retransmissions that are
> caused by duplicate ACK reception.....I have some traces that show this
> behaviour, let me know if you are interested.

I have come across this same issue. I can confirm that multiple RTOs is 
not handled correctly. But there are some other issues in FRTO as 
well... nothing extremely dangerous though. In one of the cases, the 
current FRTO algorithm could miss real losses, but you luckily need to be 
quite clever to trigger that, and due to very conservative response used 
in case spurious RTO is detected, it has no significant danger in it even 
then. The other flaws cause too conservative behavior.

We have a set of fixes to F-RTO, but part of them have not yet been 
tested. Since the fixes include 4-5 independent changes to handle also 
rare cases, it takes some time to test. Besides, I'll probably have to 
talk with Pasi Sarolahti (author of FRTO) on couple of interpretation 
issues in RFC4138 as soon as his vacation ends (mid August if I remember 
correctly) to verify some of the changes.

I expect that I'll get some actual results after two weeks or so... I case 
you're are in hurry and are interested on the fixes, I could prepare an 
independent patch quite soon and release it (untested) on our projects web 
site (if you are interested, ask off-list so that we don't bother others 
:-)). But the kernel inclusion of the fixes should IMO wait at least until 
I get some decent test cases analyzed, which will take at least two weeks 
or so due to my schedule.

> -In the cases where TCP timestamp or FRTO is not able to detect spurious
> retransmissions, the performance degrades even more than when TCP timestamp
> or FRTO option are not used....

That's one of the FRTO "features", we have a fix (I cannot say about 
timestamps since we've been running our tests without tstamps for years).


-- 
 i.
