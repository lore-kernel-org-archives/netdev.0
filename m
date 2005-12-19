From: Craig Partridge <craig@aland.bbn.com>
Subject: Re: SACK performance improvements - technical report and
	updated 2.6.6 patches
Date: Mon, 19 Dec 2005 16:45:37 -0500
Message-ID: <20051219214537.6853B4D@aland.bbn.com>
References: <43A7178E.4030808@ev-en.org>
Cc: netdev@vger.kernel.org, end2end-interest@postel.org,
   Douglas Leith <d.leith@eee.strath.ac.uk>
Return-path: <end2end-interest-bounces@postel.org>
To: Baruch Even <baruch@ev-en.org>
In-Reply-To: Your message of "Mon, 19 Dec 2005 20:26:54 GMT."
	<43A7178E.4030808@ev-en.org>
List-Unsubscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=unsubscribe>
List-Archive: <http://www.postel.org/pipermail/end2end-interest>
List-Post: <mailto:end2end-interest@postel.org>
List-Help: <mailto:end2end-interest-request@postel.org?subject=help>
List-Subscribe: <http://www.postel.org/mailman/listinfo/end2end-interest>,
	<mailto:end2end-interest-request@postel.org?subject=subscribe>
Sender: end2end-interest-bounces@postel.org
Errors-To: end2end-interest-bounces@postel.org
List-Id: netdev.vger.kernel.org


Thanks for sharing!

I found the report fun reading in the sense that I don't know of many folks
who've worked on slow path performance improvement.

However, having written some of these kinds of papers in the past, I'll point
out that before it could be considered publishable, it needs a much clearer
explanation of the algorithms in the actual code and precisely how they
were modified.  For instance, it wasn't clear to me if the SACK block
code walked the list of outstanding segments for each SACK block or walked
the list of segments once, checking all the SACK blocks (they are both
n*s algorithms, but the second algorithm will have decidedly better
performance due to locality and ordering tricks you can play).

Also, it was not clear why the revised algorithm grows as O(lost packets)
vs O(cwnd).

Thanks!

Craig

In message <43A7178E.4030808@ev-en.org>, Baruch Even writes:

>Hello,
>
>I wanted to post an update about my work for SACK performance
>improvements, I've updated the patches on our website and added a
>technical report on the work so far.
>
>It can be found at:
>http://hamilton.ie/net/research.htm#patches
>
>In summary: The Linux stack so far is unable to effectively handle
>single transfers on 1Gbps with high rtt links (220 ms rtt is what we
>tested). The sender is unable to process the ACK packets fast enough
>causing lost  ACKs and increased transfer times. Our work resulted in a
>set of patches that enable the Linux TCP stack to handle this load
>without breaking sweat.
>
>Your comments on this work would be appreciated.
>
>Regards,
>Baruch
