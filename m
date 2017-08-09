From: David Miller via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: Re: [PATCH v5 net-next 00/12] bpf: rewrite value
 tracking in verifier
Date: Tue, 08 Aug 2017 17:51:54 -0700 (PDT)
Message-ID: <20170808.175154.286461828216806349.davem@davemloft.net>
References: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
	<598909D8.5060202@iogearbox.net>
Reply-To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ast-b10kYP2dOMg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org
To: daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <598909D8.5060202-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
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

From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Date: Tue, 08 Aug 2017 02:46:16 +0200

> On 08/07/2017 04:21 PM, Edward Cree wrote:
>> This series simplifies alignment tracking, generalises bounds tracking
>> and
>>   fixes some bounds-tracking bugs in the BPF verifier.  Pointer
>>   arithmetic on
>>   packet pointers, stack pointers, map value pointers and context
>>   pointers has
>>   been unified, and bounds on these pointers are only checked when the
>>   pointer
>>   is dereferenced.
>> Operations on pointers which destroy all relation to the original
>> pointer
>>   (such as multiplies and shifts) are disallowed if
>>   !env->allow_ptr_leaks,
>>   otherwise they convert the pointer to an unknown scalar and feed it to
>>   the
>>   normal scalar arithmetic handling.
>> Pointer types have been unified with the corresponding
>> adjusted-pointer types
>>   where those existed (e.g. PTR_TO_MAP_VALUE[_ADJ] or FRAME_PTR vs
>>   PTR_TO_STACK); similarly, CONST_IMM and UNKNOWN_VALUE have been
>>   unified into
>>   SCALAR_VALUE.
>> Pointer types (except CONST_PTR_TO_MAP, PTR_TO_MAP_VALUE_OR_NULL and
>>   PTR_TO_PACKET_END, which do not allow arithmetic) have a 'fixed
>>   offset' and
>>   a 'variable offset'; the former is used when e.g. adding an immediate
>>   or a
>>   known-constant register, as long as it does not overflow.  Otherwise
>>   the
>>   latter is used, and any operation creating a new variable offset
>>   creates a
>>   new 'id' (and, for PTR_TO_PACKET, clears the 'range').
>> SCALAR_VALUEs use the 'variable offset' fields to track the range of
>> possible
>>   values; the 'fixed offset' should never be set on a scalar.
> 
> Been testing and reviewing the series over the last several days,
> looks
> reasonable to me as far as I can tell. Thanks for all the hard work on
> unifying this, Edward!
> 
> Acked-by: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>

Series applied, thanks everyone!
