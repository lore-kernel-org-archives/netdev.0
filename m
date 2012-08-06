From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/13] SCTP: Enable netns
Date: Mon, 06 Aug 2012 12:50:46 -0700
Message-ID: <874noflrzd.fsf@xmission.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com>
	<87mx27rig7.fsf@xmission.com> <50201928.2030802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jan Ariyasu <jan.ariyasu@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jan Ariyasu <jan.ariyasu@hp.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50201928.2030802@gmail.com> (Vlad Yasevich's message of "Mon, 06
	Aug 2012 15:21:12 -0400")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vlad Yasevich <vyasevich@gmail.com> writes:


> Hi Eric
>
> Associations are looked up by ports, but then verifyed by addresses.
> Also, associations belong to sockets and simply validating the socket
> namespace should be sufficient.

True.  Your set of patches isn't quite as likely to malfunction as it
looked at first glance.  It requires address reuse which happens accross
namespaces but not too frequently.

As for validating the socket namespace I agree that is the fix and my
patchset winds up doing it.

>> The downside with my version is that it does not make all of the sctp
>> tunables per network namespace the way yours does, but making all of
>> the tunables per network namespace should be straight forward from
>> my base.
>>
>> My patchset also misses some nice to haves like making the association
>> id allocation per network namespace.  It is not important for
>> correctness of the code but it might allow an information leak between
>> namespaces.
>
> Hmm.. this one might be nice to have not from the perspective of leak,
> but from resource limitation.  Without this, once the id space is
> global is can be exhausted faster.

It takes a lot of associtations to exhaust the id space, but I have no
fundamental problems problems with the id allocation being per
namespace.  I had actually overlooked the local association id when I
did my patches.   After looking it became clear that making the
association id global was not necessary so I left it.

The sctp association id is a strange beast.  My personal inclination is
that the sctp association id really ought to be per sctp socket, but I
have not looked enough at the sctp userspace API to see if that works in
practice.  Shrug.

Mostly I am in favor of simple and correct.

Eric
