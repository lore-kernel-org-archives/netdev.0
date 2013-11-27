From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH openvswitch] linux: Signal datapath that
 unaligned Netlink message can be received
Date: Wed, 27 Nov 2013 23:41:29 +0100
Message-ID: <52967519.4060509@redhat.com>
References: <48c93fb3c82bca0c9858ff528e2cf79d72d76082.1385057672.git.tgraf@redhat.com>
	<CAEP_g=9Ax4A+eKZyUXhZhqFQ8Nyi5JeQzwyqJY=rVceKZHEHNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=9Ax4A+eKZyUXhZhqFQ8Nyi5JeQzwyqJY=rVceKZHEHNw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On 11/26/2013 12:41 AM, Jesse Gross wrote:
> On Thu, Nov 21, 2013 at 10:15 AM, Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> diff --git a/lib/dpif-linux.c b/lib/dpif-linux.c
>> index 1dcf321..5c952bc 100644
>> --- a/lib/dpif-linux.c
>> +++ b/lib/dpif-linux.c
>> @@ -232,6 +233,7 @@ dpif_linux_open(const struct dpif_class *class OVS_UNUSED, const char *name,
>>           dp_request.cmd = OVS_DP_CMD_GET;
>>       }
>>       dp_request.name = name;
>> +    dp_request.user_features |= OVS_DP_F_UNALIGNED;
>
> Should we restrict this to just OVS_DP_CMD_NEW?

I'm fine either way. We currently disregard user features in GET.
