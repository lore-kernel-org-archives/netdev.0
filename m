From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 9/9] netfilter: implement xt_cgroup cgroup2 path match
Date: Mon, 23 Nov 2015 17:35:56 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CBDA8E2@AcuExch.aculab.com>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <1448122441-9335-10-git-send-email-tj@kernel.org>
 <20151121165605.GC25336@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"pablo@netfilter.org" <pablo@netfilter.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"kadlec@blackhole.kfki.hu" <kadlec@blackhole.kfki.hu>,
	"daniel@iogearbox.net" <daniel@iogearbox.net>,
	"daniel.wagner@bmw-carit.de" <daniel.wagner@bmw-carit.de>,
	"nhorman@tuxdriver.co" <nhorman@tuxdriver.co>,
	"lizefan@huawei.com" <lizefan@huawei.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-team@fb.com" <kernel-team@fb.com>,
	"ninasc@fb.com" <ninasc@fb.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"Jan Engelhardt" <jengelh@inai.de>
To: 'Florian Westphal' <fw@strlen.de>, Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:61517 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754698AbbKWRiA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 12:38:00 -0500
In-Reply-To: <20151121165605.GC25336@breakpoint.cc>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal
> Sent: 21 November 2015 16:56
> > +struct xt_cgroup_info_v1 {
> > +	__u8		has_path;
> > +	__u8		has_classid;
> > +	__u8		invert_path;
> > +	__u8		invert_classid;
> > +	char		path[PATH_MAX];
> > +	__u32		classid;
> > +
> > +	/* kernel internal data */
> > +	void		*priv __attribute__((aligned(8)));
> > +};
> 
> Ahem.  Am I reading this right? This struct is > 4k in size?
> If so -- Ugh.  Does sizeof(path) really have to be PATH_MAX?

I've not looked at the use, but could you put 'char path[];'
as the last member an require any allocations to be long enough
to contain the actual path?

	David
