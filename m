From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [RFC PATCH 2/2] bpf: Implement
 bpf_perf_event_sample_enable/disable() helpers
Date: Mon, 12 Oct 2015 20:39:06 -0700
Message-ID: <561C7CDA.8050004@plumgrid.com>
References: <1444640563-159175-1-git-send-email-xiakaixu@huawei.com>
 <1444640563-159175-3-git-send-email-xiakaixu@huawei.com>
 <561C0A1E.2080500@plumgrid.com> <561C7A1F.6040702@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, pi3orama@163.com, hekuang@huawei.com,
	netdev@vger.kernel.org
To: "Wangnan (F)" <wangnan0@huawei.com>,
	Kaixu Xia <xiakaixu@huawei.com>, davem@davemloft.net,
	acme@kernel.org, mingo@redhat.com, a.p.zijlstra@chello.nl,
	masami.hiramatsu.pt@hitachi.com, jolsa@kernel.org,
	daniel@iogearbox.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <561C7A1F.6040702@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/12/15 8:27 PM, Wangnan (F) wrote:
> Then how to avoid racing? For example, when one core disabling all events
> in a map, another core is enabling all of them. This racing may causes
> sereval
> perf events in a map dump samples while other events not. To avoid such
> racing
> I think some locking must be introduced, then cost is even higher.
>
> The reason why we introduce an atomic pointer is because each operation
> should
> controls a set of events, not one event, due to the per-cpu manner of
> perf events.

why 'set disable' is needed ?
the example given in cover letter shows the use case where you want
to receive samples only within sys_write() syscall.
The example makes sense, but sys_write() is running on this cpu, so just
disabling it on the current one is enough.
