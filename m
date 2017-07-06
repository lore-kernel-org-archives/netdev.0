From: Nadav Amit via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 02/12] bpf/verifier: rework
 value tracking
Date: Thu, 6 Jul 2017 14:21:46 -0700
Message-ID: <E65DE75F-FC5F-41BC-9F7B-C03D324D8C6F@gmail.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
Reply-To: Nadav Amit <nadav.amit-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <2244b48b-f415-3239-6912-cb09f0abc546-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org> wrote:

> Tracks value alignment by means of tracking known & unknown bits.
> Tightens some min/max value checks and fixes a couple of bugs therein.
> If pointer leaks are allowed, and adjust_ptr_min_max_vals returns -EACCES,
> treat the pointer as an unknown scalar and try again, because we might be
> able to conclude something about the result (e.g. pointer & 0x40 is either
> 0 or 0x40).
> 
> Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
> ---
> include/linux/bpf.h          |   34 +-
> include/linux/bpf_verifier.h |   40 +-
> include/linux/tnum.h         |   79 ++
> kernel/bpf/Makefile          |    2 +-
> kernel/bpf/tnum.c            |  163 ++++
> kernel/bpf/verifier.c        | 1692 ++++++++++++++++++++++++------------------
> 6 files changed, 1235 insertions(+), 775 deletions(-)

(RESEND)

I find it a bit surprising that such huge changes that can affect security
and robustness are performed in one patch. Personally, I cannot comprehend
all of these changes. In addition, I think that it is valuable to describe
in detail the bugs that the patch solves and when they were introduced.

I can bring up some concerns regarding inconsistencies in offset checks and
size, not spilling SCALAR and my wish not to limit packet size. However,
when the patch is that big, I think it is useless.

Nadav
