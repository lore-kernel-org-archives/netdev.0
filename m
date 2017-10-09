From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V5 PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Mon, 09 Oct 2017 22:56:33 +0200
Message-ID: <59DBE281.1030007@iogearbox.net>
References: <150730632837.22839.11804085686478888137.stgit@firesoul>        <150730636196.22839.17119032803741721925.stgit@firesoul>        <59DB7A29.5050906@iogearbox.net> <20171009195924.662f1586@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48607 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754188AbdJIU4h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 16:56:37 -0400
In-Reply-To: <20171009195924.662f1586@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2017 07:59 PM, Jesper Dangaard Brouer wrote:
[...]
>>> +static void *cpu_map_lookup_elem(struct bpf_map *map, void *key)
>>> +{
>>> +	struct bpf_cpu_map_entry *rcpu =
>>> +		__cpu_map_lookup_elem(map, *(u32 *)key);
>>> +
>>> +	return rcpu ? &rcpu->qsize : NULL;
>>
>> I still think from my prior email/comment that we should use per-cpu
>> scratch buffer here. Would be nice to keep the guarantee that noone
>> can modify it, it's just a tiny change.
>
> Well, it's no-longer really needed, right(?), as this patchset update,
> change that bpf-side cannot invoke this.  The userspace-side reading
> this will get a copy.

Ah sorry, you're right, the related change happens in later patch, I
missed that; would be good to avoid a split in future or other option
is to forbid usage initially in check_map_func_compatibility() by
bailing out in BPF_MAP_TYPE_CPUMAP case unconditionally, and then
enabling it for BPF_FUNC_redirect_map in next step, such that should
someone accidentally only backport this patch, we don't allow for
unintended misuse.

Thanks,
Daniel
