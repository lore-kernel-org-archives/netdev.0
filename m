From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 00/12] bpf: rewrite value
	tracking in verifier
Date: Thu, 6 Jul 2017 15:07:20 +0100
Message-ID: <5922c77e-0476-c4a8-3bf2-e502ee3acb8f@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<5953B436.6030506@iogearbox.net>
	<788035e1-1974-b48e-3008-d294194a8b05@solarflare.com>
	<595413AA.40502@iogearbox.net>
	<20170628213701.32krfuipzngsmt4k@ast-mbp>
	<91267d15-652a-16d9-4ee9-42958bd842aa@solarflare.com>
	<ff1ef3ef-71ef-4c23-ede4-b8caeac561ee@fb.com>
	<5fa61129-fa82-1607-3363-dfad86aecf1e@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Alexei Starovoitov
	<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <5fa61129-fa82-1607-3363-dfad86aecf1e-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/07/17 20:22, Edward Cree wrote:
> I don't know why test_l4lb has to process _fewer_ insns with my patches;
>  if anything I'm worrying that I may be incorrectly pruning branches.
> (I've spotted a possible bug in that I'm not looking at 'id' which,
>  although it doesn't have to match, if two regs in the old state had the
>  same id as each other, then those regs in the new state have to have
>  the same id as each other too.)
I've now fixed that bug, and also changing it to not fill in 'id' on pointers
 other than PTR_TO_PACKET when doing arithmetic (because it's only used for
 'range' sharing and only PTR_TO_PACKET have that.  Of course
 PTR_TO_MAP_VALUE_OR_NULL still use id, but they don't get it from arithmetic).
Changes will be in next version of patch series, but for now:
Program         net-next  short  full   new
test_pkt_access       78     79    79    79
test_xdp             386    411   407   389
test_l4lb           6438   4154  4154  4062
test_tcp_estats      435    436   435   435
test_bpf_obj_id        8      8     8     8
test_pkt_md_access    41     42    42    42
As you can see, the #insns has gone down even further.

-Ed
