From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 2/2[ Traffic control cgroups subsystem
Date: Fri, 25 Jul 2008 11:29:42 +0800
Message-ID: <488948A6.2050408@cn.fujitsu.com>
References: <Pine.LNX.4.64.0807241635460.30437@ranjit.corp.google.com> <1216954937.22487.1.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: Ranjit Manomohan <ranjitm@google.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	menage@google.com, kaber@trash.net, akpm@linux-foundation.org
To: Daniel Walker <dwalker@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:62653 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751243AbYGYDbT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 23:31:19 -0400
In-Reply-To: <1216954937.22487.1.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Walker wrote:
> On Thu, 2008-07-24 at 16:37 -0700, Ranjit Manomohan wrote:
> 
> 
>> +/* Delete one filter entry */
>> +static int cgroup_delete(struct tcf_proto *tp, unsigned long arg)
>> +{
>> +	struct cgroup_head *head = (struct cgroup_head *) tp->root;
>> +	struct cgroup_filter *t, *f = (struct cgroup_filter *) arg;
>> +
>> +	list_for_each_entry(t, &head->flist, link)
>> +		if (t == f) {
>> +			tcf_tree_lock(tp);
>> +			list_del(&t->link);
> 
> Doesn't the above need to be a "_safe" list operation since your
> deleting the element?
> 

No. You don't need "_safe" if you break out the loop immediately
after list_del().

