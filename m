From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][PATCH net] bpf: Use mount_nodev not mount_ns to mount the bpf filesystem
Date: Fri, 20 May 2016 17:31:24 -0500
Message-ID: <8737pce4zn.fsf@x220.int.ebiederm.org>
References: <87oa84wa6h.fsf@x220.int.ebiederm.org>
	<79e26212-3b09-1be3-0fbf-30de1b265045@stressinduktion.org>
	<87inybv2hv.fsf@x220.int.ebiederm.org>
	<573CD3D8.3030308@iogearbox.net>
	<bbb5386f-b7ea-a256-5dfd-c8c8681061c6@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:48448 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032AbcETWmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 18:42:24 -0400
In-Reply-To: <bbb5386f-b7ea-a256-5dfd-c8c8681061c6@stressinduktion.org>
	(Hannes Frederic Sowa's message of "Wed, 18 May 2016 22:46:57 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> On 18.05.2016 22:43, Daniel Borkmann wrote:
>> Eric, please send the patch officially and feel free to add my Ack.

Done.

>> Given
>> the circumstances, moving to mount_nodev() seems the best way forward. To
>> also address above mentioned concern from Hannes, we need to remove the
>> FS_USERNS_MOUNT flag along with the change. It looks like the fix is best
>> addressed in a single patch if you want to include it. If not, we can
>> otherwise send it separately as well, I don't mind.
>
> I agree. Would make most sense to make the change in one patch. Later on
> we can reason about if it makes sense to use the net namespace to split
> bpf maps and programs or maybe even introduce a new primitive for that.

I will let you two take care of the FS_USERNS_MOUNT flag.

Removal of the FS_USERNS_MOUNT flag because it was added prematurely is
a completely different analysis of consequences and possible regressions
in userspace.  The two changes should be kept separate to make it easy
to handle the unlikely case that either of them cause a regression.

But I have not objections to removing the FS_USERNS_MOUNT flag from the
bpf filesystem.

Eric
