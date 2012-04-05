From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: kernel BUG at include/net/netns/generic.h:41
Date: Thu, 05 Apr 2012 20:08:31 +0400
Message-ID: <4F7DC37F.7090404@parallels.com>
References: <20120328002346.GB3077@redhat.com>	 <20120402172600.GA3728@redhat.com> <1333390230.13718.34.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
	Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:33010 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754221Ab2DEQIz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 12:08:55 -0400
In-Reply-To: <1333390230.13718.34.camel@lade.trondhjem.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

02.04.2012 22:10, Myklebust, Trond =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> This looks related to the recent net namespace changes, so I'm adding
> Stanislav.
>

Hi, Trond.
Looks like we stepped into exactly that situation, what Al Viro was tal=
king on=20
LFS about early registering of file system before other module "init" o=
perations=20
completed.
I.e. SUNRPC registers it's file system, and then we have races between=20
register_pernet_subsys() call and mount of SUNRPC PipeFS.
BTW, these races can be triggered only if mount of SUNRPC PipeFS is cal=
led prior=20
to SUNRPC module insertion is completed. In spite of it, I'll send the =
patch soon.
But I'm not 100% sure, that this patch will solve Dave's problem.
So, there are few questions to you, Dave:
1) can this happen (PipeFS mount attempt before SUNPRC module insertion=
 has=20
returned any value) in your case?
2) how often do you experience this problem? Not every boot, I suppose?
3) And is it easy for you to reproduce?

--=20
Best regards,
Stanislav Kinsbursky
