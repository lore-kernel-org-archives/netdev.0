From: Julian Anastasov <ja@ssi.bg>
Subject: Re: unregister_netdevice warnings when deleting netns
Date: Tue, 29 Sep 2015 09:03:40 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1509290858500.2072@ja.home.ssi.bg>
References: <CAGGTERmzF7oYABWUR+6UhddpOCtpkciVUMUOU-OcPkQvMznS8Q@mail.gmail.com> <alpine.LFD.2.11.1509282202270.7276@ja.home.ssi.bg> <8737xy5is2.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Anand Gurram <anandarao.gurram@gmail.com>,
	NETDEV <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46338 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753740AbbI2GDo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 02:03:44 -0400
In-Reply-To: <8737xy5is2.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Mon, 28 Sep 2015, Eric W. Biederman wrote:

> Julian Anastasov <ja@ssi.bg> writes:
> 
> > On Mon, 28 Sep 2015, Anand Gurram wrote:
> >
> >> I am currently using kernel version 3.16.7 on a linux switch.
> >> While creating and destroying network namespaces I am observing below logs
> >> on the console
> >> "unregister_netdevice: waiting for lo to become free. Usage count = 1"
> >> 
> >> Can you please suggest and provide instructions on how to debug this issue.
> >> If any fix already available can you please point me to the link.
> >
> > 	There are two commits from Linux 4.2 that may help:
> >
> > commit e9e4dd3267d0 ("net: do not process device backlog during unregistration")
> > commit 2c17d27c36dc ("net: call rcu_read_lock early in process_backlog")
> >
> If that message repeats indefinitely it means there is a leaked
> reference to the network namespaces lo device.
> 
> If the message just spits out a few times and then goes away it simply
> means that something is taking a while to cleanup and drop it's
> reference.
> 
> This is slightly complicated by the fact that it is not uncommon when a
> network device goes away to redirect all references to itself to the lo
> device.

	Yes, there is a little chance with forwarding disabled,
i.e. when presence of "ipv4: Avoid crashing in ip_error" does
not matter, flying packet to leave new reference somewhere,
without crashing. But it may be another problem, of course.

Regards

--
Julian Anastasov <ja@ssi.bg>
