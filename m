From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH 00/13] SCTP: Enable netns
Date: Mon, 06 Aug 2012 15:21:12 -0400
Message-ID: <50201928.2030802@gmail.com>
References: <1344115837-6150-1-git-send-email-jan.ariyasu@hp.com> <87mx27rig7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Ariyasu <jan.ariyasu@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jan Ariyasu <jan.ariyasu@hp.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:51776 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756675Ab2HFTVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 15:21:17 -0400
In-Reply-To: <87mx27rig7.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/06/2012 02:20 PM, Eric W. Biederman wrote:
> Jan Ariyasu <jan.ariyasu@gmail.com> writes:
>
>> The following set of patches enable network-namespaces for the SCTP protocol.
>>
>> The multitude of global parameters are stored in a net_generic
>> structure, and the bulk of the patches enable the protocol to access
>> the parameters on a per-namespace basis.  The first five patches
>> enable netns handling of the protocol, procfs and sysfs.
>
> I am going to do something to muddy the waters here, that I had hoped to
> avoid when I saw your patchset.
>
> A few weeks ago I wanted to play with sctp and also made a network
> namespace enabled version.  I am not deeply attached to my changes,
> however when comparing the differences I realized that your code fails
> to make the lookup of associations per network namespace.
>
> Given that we only have source and destination port to lookup
> assoications by this almost guarantees one network namespace can
> accidentially use the association of another network namespace meerly
> by reusing the same ports.
>

Hi Eric

Associations are looked up by ports, but then verifyed by addresses.
Also, associations belong to sockets and simply validating the socket 
namespace should be sufficient.


> The downside with my version is that it does not make all of the sctp
> tunables per network namespace the way yours does, but making all of
> the tunables per network namespace should be straight forward from
> my base.
>
> My patchset also misses some nice to haves like making the association
> id allocation per network namespace.  It is not important for
> correctness of the code but it might allow an information leak between
> namespaces.

Hmm.. this one might be nice to have not from the perspective of leak, 
but from resource limitation.  Without this, once the id space is global 
is can be exhausted faster.

-vlad

>
> So Jan I am going to send my patchset and hopefully you can rebase your
> changes to make all of the tunables per network namespace on top of
> mine.
>
> Since my patchset is half the size of your I think that is the most
> reasonable way to go.
>
> Eric
>
