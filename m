From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: Request to include ESFQ patch
Date: Mon, 7 Jan 2008 06:46:29 +0200
Message-ID: <20080107043027.M83313@visp.net.lb>
References: <20080102155903.M66678@visp.net.lb> <478133A4.4020903@andyfurniss.entadsl.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org, bugfood-c@fatooh.org
To: lists@andyfurniss.entadsl.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:42671 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbYAGEqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jan 2008 23:46:39 -0500
In-Reply-To: <478133A4.4020903@andyfurniss.entadsl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 06 Jan 2008 20:01:40 +0000, Andy Furniss wrote
> Denys Fedoryshchenko wrote:
> > Hi
> > 
> > I took risk and installed ESFQ on my main backbone QoS. I found it highly 
> > useful, and very need in setup's where is more than 128 flows passing and 
> > especially where is nat available.
> 
> I agree it will be good when it's in.
> 
> > 
> > Here is results with overloaded class for low-priority P2P traffic customers:
> >
> 
> *sfq was never meant for interactive traffic as such. If you really 
> want to do QOS for them you would need to (somehow) classify 
> interactive and give it prio over bulk. I know this may not be 
> practical for your setup, but what ping times users get will vary 
> depending how many other active users there are/queue length/how 
> many tcps the user has open etc.

In this specific setup i have a lot of classes just for type of traffic and
with priority, with many levels of hierarchy (root, realtime low bw
apps(inside also separation for few levels, and next step is specific
applications), realtime high bw apps, p2p low priority high bw and etc), plus
i have at root separation for types of customers. 

But because even with this, i have few thousands of IP's, and after all if i
will create classes for each customer i will not fit in 65k of classes, plus i
will face performance issues, even if i will use hashes in filters. Instead
doing a thousands of classes, i group traffic and customers types and inside
distribute traffic fairly by ESFQ. ESFQ do the job perfectly. 
SFQ for example cause of limit 128 flows will mess up with VoIP and other
applications for whom is critical packet ordering.

ESFQ does good job to prevent one dst IP inside group (for example) taking
prevailing part of bandwidth. Or to prevent one source to do same thing. Or
whatever - depends on hash type. It is not corrupting packet ordering on
non-classic hash type.

Btw in test i used ping just to get statistics how traffic passing class, how
bandwidth of single user affected with different qdiscs, and etc. If i see
some problem with specific type of bandwidth, i can forward ping with specific
ToS to that class by filters and i can compare regular ping with ToS'ed ping,
to see if issue caused by shaper, router,backbone provider or whatever.


> 
> Andy.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

