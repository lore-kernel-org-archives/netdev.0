From: Abel Gordon <ABELG@il.ibm.com>
Subject: Re: provide vhost thread per virtqueue for forwarding scenario
Date: Mon, 20 May 2013 11:16:03 +0300
Message-ID: <OF2D1D6163.08173A32-ONC2257B71.002CA3E8-C2257B71.002D6A76@il.ibm.com>
References: <5872DA217C2FF7488B20897D84F904E7338FC974@nkgeml511-mbx.china.huawei.com> <20130520074300.GA27848@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kvm-owner@vger.kernel.org,
	"nab@linux-iscsi.org" <nab@linux-iscsi.org>,
	" (netdev@vger.kernel.org)" <netdev@vger.kernel.org>,
	"rusty@rustcorp.com.au" <rusty@rustcorp.com.au>,
	Zanghongyong <zanghongyong@huawei.com>,
	"Zhangjie (HZ)" <zhang.zhangjie@huawei.com>, nyharel@gmail.com,
	"Muli Ben-Yehuda" <mulix@mulix.org>, orit.was@gmail.com,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Qinchuanyu <qinchuanyu@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:47997 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755084Ab3ETIQK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 04:16:10 -0400
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <abelg@il.ibm.com>;
	Mon, 20 May 2013 09:14:08 +0100
In-Reply-To: <20130520074300.GA27848@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



"Michael S. Tsirkin" <mst@redhat.com> wrote on 20/05/2013 10:43:00 AM:

> >
> > I did the test with kernel 3.0.27 and qemu-1.4.0, guest is suse11-
> sp2, and then two vhost thread provide
> > double tx/rx forwarding performance than signal vhost thread.
> > The virtqueue of vhost_blk is 1, so it still use one vhost thread
> without change.
> >
> > Is there something wrong in this solution? If not, I would list patch
later.
> >
> > Best regards
> > King
>
> Yes, I don't think we want to create threads even more aggressively
> in all cases. I'm worried about scalability as it is.
> I think we should explore a flexible approach, use a thread pool
> (for example, a wq) to share threads between virtqueues,
> switch to a separate thread only if there's free CPU and existing
> threads are busy. Hopefully share threads between vhost instances too.
>

Qinchuanyu, you can take a look at the following tech. report
http://domino.research.ibm.com/library/cyberdig.nsf/1e4115aea78b6e7c85256b360066f0d4/479e3578ed05bfac85257b4200427735!OpenDocument


which actually shows the scalability problem Michael mentioned when
you run multiple vhost-threads.

Regards,
Abel.
