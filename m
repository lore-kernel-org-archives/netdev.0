From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 3/5] change number_of_cpusets to an atomic
Date: Tue, 24 Apr 2012 10:02:02 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1204241001050.26005@router.home>
References: <1335209867-1831-1-git-send-email-glommer@parallels.com> <1335209867-1831-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org,
	cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>,
	kamezawa.hiroyu@jp.fujitsu.com, David Miller <davem@davemloft.net>,
	devel@openvz.org
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp110.prem.mail.ac4.yahoo.com ([76.13.13.93]:43535 "HELO
	smtp110.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755175Ab2DXPCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 11:02:06 -0400
In-Reply-To: <1335209867-1831-4-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Apr 2012, Glauber Costa wrote:

> This will allow us to call destroy() without holding the
> cgroup_mutex(). Other important updates inside update_flags()
> are protected by the callback_mutex.
>
> We could protect this variable with the callback_mutex as well,
> as suggested by Li Zefan, but we need to make sure we are protected
> by that mutex at all times, and some of its updates happen inside the
> cgroup_mutex - which means we would deadlock.

Would this not also be a good case to introduce static branching?

number_of_cpusets is used to avoid going through unnecessary processing
should there be no cpusets in use.
