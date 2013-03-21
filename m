From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -next] openvswitch: fix error return code in
	ovs_vport_cmd_set()
Date: Wed, 20 Mar 2013 17:06:56 -0700
Message-ID: <CAEP_g=9f4TVsLAyRt9WkOagYO3-kuEO+TVPjGSr0kB94VsCg7A@mail.gmail.com>
References: <CAPgLHd_6+xnMKZBzH3KySpFv7hUzzNot7GBYSCAPLDRbC5HjsA@mail.gmail.com>
	<CAEP_g=8zxp4jcNN93iEGzA2aNbmM7g+=PaWbTEyJiwzwS5Qnsg@mail.gmail.com>
	<20130320.122213.135318342578938888.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org,
	weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20130320.122213.135318342578938888.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 20, 2013 at 9:22 AM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> From: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
> Date: Wed, 20 Mar 2013 08:57:53 -0700
>
>> On Wed, Mar 20, 2013 at 5:14 AM, Wei Yongjun <weiyj.lk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> From: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
>>>
>>> Fix to return a negative error code from the error handling
>>> case instead of 0, as returned elsewhere in this function.
>>>
>>> Signed-off-by: Wei Yongjun <yongjun_wei-zrsr2BFq86L20UzCJQGyNP8+0UxHXcjY@public.gmane.org>
>>
>> This isn't right because at this point in the function the change has
>> already been made, only the notification allocation failed.  Therefore
>> we don't want to return an error since the caller will assume that
>> nothing has changed; instead an error is set on the Netlink socket.
>
> Then the way to fix this is to allocate the netlink SKB first, before
> any config changes occur, then pass that SKB into ovs_vport_cmd_build_info.
>
> We can still get errors, for -EMSGSIZE situations, but I'd say that'd
> be an implementation bug that should be logged.  If we aren't allocating
> large enough SKBs for the netlink reply, that's really an internal
> error.

That solves the problem here.  I'll take care of it, thanks.
