From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [patch 2/6] [Network namespace] Network device sharing by view
Date: Tue, 27 Jun 2006 10:40:18 -0600
Message-ID: <m1u066lfgt.fsf@ebiederm.dsl.xmission.com>
References: <20060609210625.144158000@localhost.localdomain>
	<20060626134711.A28729@castle.nmd.msu.ru>
	<449FF5A0.2000403@fr.ibm.com> <20060626192751.A989@castle.nmd.msu.ru>
	<44A00215.2040608@fr.ibm.com>
	<m1hd27uaxw.fsf@ebiederm.dsl.xmission.com>
	<20060626183649.GB3368@MAIL.13thfloor.at>
	<m1u067r9qk.fsf@ebiederm.dsl.xmission.com>
	<20060626200225.GA5330@MAIL.13thfloor.at>
	<20060627130911.A13959@castle.nmd.msu.ru>
	<20060627154818.GA28984@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Lezcano <dlezcano@fr.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, serue@us.ibm.com, haveblue@us.ibm.com,
	clg@fr.ibm.com, Andrew Morton <akpm@osdl.org>, dev@sw.ru,
	devel@openvz.org, sam@vilain.net, viro@ftp.linux.org.uk,
	Alexey Kuznetsov <alexey@sw.ru>,
	Andrey Savochkin <saw@swsoft.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161177AbWF0Qm3@vger.kernel.org>
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20060627154818.GA28984@MAIL.13thfloor.at> (Herbert Poetzl's
	message of "Tue, 27 Jun 2006 17:48:19 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl <herbert@13thfloor.at> writes:

> On Tue, Jun 27, 2006 at 01:09:11PM +0400, Andrey Savochkin wrote:
>> 
>> I'd like to caution about over-optimizing communications between
>> different network namespaces. Many optimizations of local traffic
>> (such as high MTU) don't look so appealing when you start to think
>> about live migration of namespaces.
>
> I think the 'optimization' (or to be precise: desire
> not to sacrifice local/loopback traffic for some use
> case as you describe it) does not interfere with live
> migration at all, we still will have 'local' and 'remote'
> traffic, and personally I doubt that the live migration
> is a feature for the masses ...

Several things.
- The linux loopback device is not strongly optimized, it is a compatibility
  layer.
- Traffic between guests is an implementation detail.
  There is nothing fundamental in our semantics that says the traffic
  has to be slow for any workload (except for the limuts imposed by using
  actual on the wire protocols).  The lo shares the same problem.

Worry about this case now when it has clearly been shown that there are several
possible ways to optimize this and get back any lost local performance is
optimizing way too early.

Criticize the per namespace performance and all you want.  That is pretty
much a merge blocker.  Unless we do worse than a 1-5% penalty the communication
across namespaces is really a non-issue.

Even with your large communications flows between guests 1-5% is nothing.

Eric
