From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 1/7] bpf: add 'flags' attribute to BPF_MAP_UPDATE_ELEM
 command
Date: Tue, 04 Nov 2014 10:25:29 +0100
Message-ID: <54589B89.5000309@redhat.com>
References: <1415069656-14138-1-git-send-email-ast@plumgrid.com> <1415069656-14138-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34627 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751160AbaKDJZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Nov 2014 04:25:43 -0500
In-Reply-To: <1415069656-14138-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2014 03:54 AM, Alexei Starovoitov wrote:
> the current meaning of BPF_MAP_UPDATE_ELEM syscall command is:
> either update existing map element or create a new one.
> Initially the plan was to add a new command to handle the case of
> 'create new element if it didn't exist', but 'flags' style looks
> cleaner and overall diff is much smaller (more code reused), so add 'flags'
> attribute to BPF_MAP_UPDATE_ELEM command with the following meaning:
> enum {
>    BPF_MAP_UPDATE_OR_CREATE = 0, /* add new element or update existing */
>    BPF_MAP_CREATE_ONLY,          /* add new element if it didn't exist */
>    BPF_MAP_UPDATE_ONLY           /* update existing element */
> };

 From you commit message/code I currently don't see an explanation why
it cannot be done in typical ``flags style'' as various syscalls do,
i.e. BPF_MAP_UPDATE_OR_CREATE rather represented as ...

   BPF_MAP_CREATE | BPF_MAP_UPDATE

Do you expect more than 64 different flags to be passed from user space
for BPF_MAP?

> BPF_MAP_CREATE_ONLY can fail with EEXIST if element already exists.
> BPF_MAP_UPDATE_ONLY can fail with ENOENT if element doesn't exist.
>
> Userspace will call it as:
> int bpf_update_elem(int fd, void *key, void *value, __u64 flags)
> {
>      union bpf_attr attr = {
>          .map_fd = fd,
>          .key = ptr_to_u64(key),
>          .value = ptr_to_u64(value),
>          .flags = flags;
>      };
>
>      return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
> }
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
