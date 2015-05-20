From: Alex Gartrell <agartrell@fb.com>
Subject: We've released a generic netlink python library -- gnlpy
Date: Wed, 20 May 2015 14:10:19 -0700
Message-ID: <555CF83B.7040706@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kernel-team@fb.com>
To: <lvs-devel@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey everyone,

tl;dr; pure python generic netlink library with simple clients for ipvs 
and taskstats here: https://github.com/facebook/gnlpy

At Facebook we rely upon ipvs for most of our layer-4 load balancing 
needs.  It's mostly worked pretty great for us.  The standard way to 
interact with ipvs is ipvsadm, which will use netlink sockets to make 
rpc calls to the kernel (things like adding/remove services and real 
servers).  Because we run many, many instances of ipvs, we ended up 
scripting this away with a separate program that shells out to ipvsadm.

The down side to this approach was that we had to format the arguments 
and parse the result of the tool, which was kind of a pain. 
Additionally, we'd sometimes get into a bad state where the exec would 
fail or the binary wouldn't be there and the whole thing would kind of 
break.  To my knowledge this never caused any kind of large scale 
incident, but it was an annoying thing to deal with.

At some point, we made some changes to ipvs (heterogenous pools) and we 
were in the position of needing to roll a new ipvsadm binary to take 
advantage of the functionality.  That was fundamentally unappealing to 
yours truly, so I hacked together gnlpy (Generic NetLink PYthon library) 
instead.  It's been in production for several months.

At some point thereafter, someone on the lvs-devel list mentioned 
wanting to interact with ipvs through python and I made a vague 
assurance that we'd open source this thing.  Well here we are.

If you take a look at the code, you'll quickly notice that we haven't 
gone through the trouble of implementing every RPC call for the families 
we support and we certainly haven't gone through the trouble of 
implementing every generic netlink family.  We welcome your pull requests :)

-- 
Alex Gartrell <agartrell@fb.com>
