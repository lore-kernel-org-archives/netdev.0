From: Daniel Borkmann via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next] bpf/verifier: track liveness
	for pruning
Date: Mon, 21 Aug 2017 22:27:29 +0200
Message-ID: <599B4231.3080405@iogearbox.net>
References: <f40d3d54-c88a-7348-99ca-66db8075a8d5@solarflare.com>
	<89ff34f7-84ee-0e0a-3766-5b4d046189bf@fb.com>
	<b8a46388-74ea-81f9-df08-3b6b88042229@solarflare.com>
	<5d4e12aa-6861-a176-a8cf-a766bbca0a7a@fb.com>
	<b39b4a6f-907e-c684-b9e4-285ff9c7ca9a@solarflare.com>
Reply-To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <b39b4a6f-907e-c684-b9e4-285ff9c7ca9a-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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

On 08/21/2017 08:36 PM, Edward Cree wrote:
> On 19/08/17 00:37, Alexei Starovoitov wrote:
[...]
> I'm tempted to just rip out env->varlen_map_value_access and always check
>   the whole thing, because honestly I don't know what it was meant to do
>   originally or how it can ever do any useful pruning.  While drastic, it
>   does cause your test case to pass.

Original intention from 484611357c19 ("bpf: allow access into map
value arrays") was that it wouldn't potentially make pruning worse
if PTR_TO_MAP_VALUE_ADJ was not used, meaning that we wouldn't need
to take reg state's min_value and max_value into account for state
checking; this was basically due to min_value / max_value is being
adjusted/tracked on every alu/jmp ops for involved regs (e.g.
adjust_reg_min_max_vals() and others that mangle them) even if we
have the case that no actual dynamic map access is used throughout
the program. To give an example on net tree, the bpf_lxc.o prog's
section increases from 36,386 to 68,226 when env->varlen_map_value_access
is always true, so it does have an effect. Did you do some checks
on this on net-next?
