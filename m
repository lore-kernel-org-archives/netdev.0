From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v3 net-next 02/12] bpf/verifier: rework
	value tracking
Date: Wed, 28 Jun 2017 19:28:27 +0100
Message-ID: <7bae321b-c0ac-ddea-3abf-a30d940a9f89@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
	<2244b48b-f415-3239-6912-cb09f0abc546@solarflare.com>
	<5953E2E5.7040106@iogearbox.net>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, "Alexei
	Starovoitov" <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <5953E2E5.7040106-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
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

On 28/06/17 18:09, Daniel Borkmann wrote:
> Could you elaborate on this one? If I understand it correctly, then
> the scalar += pointer case would mean the following: given I have one
> of the allowed pointer types in adjust_ptr_min_max_vals() then the
> prior scalar type inherits the ptr type/id. I would then 'destroy' the
> pointer value so we get a -EACCES on it. We mark the tmp off_reg as
> scalar type, but shouldn't also actual dst_reg be marked as such
> like in below pointer += scalar case, such that we undo the prior
> ptr_type inheritance?
Good catch.  The intent was that adjust_ptr_min_max_vals() wouldn't mark
 dst_reg's type/id in the case when it returned -EACCES, but indeed there
 are some such paths, and rather than changing those it may be easier to
 change the type/id back to scalar/0.  I don't think we need to go as far
 as calling __mark_reg_unknown() on it though, its bounds and align
 shouldn't have been screwed up by adjust_ptr_min_max_vals().

-Ed
