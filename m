From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] samples/bpf: Fix test_maps/bpf_get_next_key() test
Date: Thu, 22 Jan 2015 09:32:43 -0800
Message-ID: <CAADnVQ+3exrhp8bS50HEnMrYdg4i3+K7c6ewNZHRkBqtW-uwOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 22, 2015 at 8:01 AM, Michael Holzheu
<holzheu@linux.vnet.ibm.com> wrote:
> Looks like the "test_maps" test case expects to get the keys in
> the wrong order when iterating over the elements:
>
> test_maps: samples/bpf/test_maps.c:79: test_hashmap_sanity: Assertion
> `bpf_get_next_key(map_fd, &key, &next_key) == 0 && next_key == 2' failed.
> Aborted
>
> Fix this and test for the correct order.

that will break this test on x86...
we need to understand first why the order of two elements
came out different on s390...
Could it be that jhash() produced different hash for the same
values on x86 vs s390 ?
The better fix for the test is probably not to assume AB or BA
order, but accept both.
