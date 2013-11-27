From: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH openvswitch] netlink: Implement & enable
 memory mapped netlink i/o
Date: Wed, 27 Nov 2013 23:51:20 +0100
Message-ID: <52967768.8090308@redhat.com>
References: <2336aeee25d64eab89302c28c33b7cb7d1a55560.1385057738.git.tgraf@redhat.com>
	<20131125230253.GR1435@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fleitner-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <20131125230253.GR1435-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

On 11/26/2013 12:02 AM, Ben Pfaff wrote:
> On Thu, Nov 21, 2013 at 07:16:54PM +0100, Thomas Graf wrote:
>> Based on the initial patch by Cong Wang posted a couple of months
>> ago.
>>
>> This is the user space counterpart needed for the kernel patch
>> '[PATCH net-next 3/8] openvswitch: Enable memory mapped Netlink i/o'
>>
>> Allows the kernel to construct Netlink messages on memory mapped
>> buffers and thus avoids copying. The functionality is enabled on
>> sockets used for unicast traffic.
>>
>> Further optimizations are possible by avoiding the copy into the
>> ofpbuf after reading.
>>
>> Cc: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> Signed-off-by: Thomas Graf <tgraf-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>
> Does this depend on other patches or some specific Linux kernel
> headers?  It doesn't build here on GCC (similar results with Clang):

Yes, it depends on a sufficiently recent <linux/netlink.h>. We can
either #ifdef the mmap code or we provide a local copy of
<linux/netlink.h> in include/linux. The code automatically falls back if
the kernel does not support NL MMAP so that seems superior.

What do you prefer?
