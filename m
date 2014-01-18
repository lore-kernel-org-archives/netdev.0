From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/6] cgroup: make CONFIG_NET_CLS_CGROUP and
	CONFIG_NETPRIO_CGROUP bool instead of tristate
Date: Sat, 18 Jan 2014 12:25:43 +0100
Message-ID: <52DA64B7.3030909@redhat.com>
References: <1389982317-22225-1-git-send-email-tj@kernel.org>
	<1389982317-22225-2-git-send-email-tj@kernel.org>
	<52D9D421.6040608@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <52D9D421.6040608-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/18/2014 02:08 AM, Li Zefan wrote:
> Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> 
> On 2014/1/18 2:11, Tejun Heo wrote:
>> net_cls and net_prio are the only cgroups which are allowed to be
>> built as modules.  The savings from allowing the two controllers to be
>> built as modules are tiny especially given that cgroup module support
>> itself adds quite a bit of complexity.
>>
>> The following are the sizes of vmlinux with both built as module and
>> both built as part of the kernel image with cgroup module support
>> removed.
>>
>> 	text		data		bss		dec
>> 	20292207	2411496		10784768	33488471
>> 	20293421	2412568		10784768	33490757
>>
>> The total difference is 2286 bytes.  Given that none of other
>> controllers has much chance of being made a module and that we're
>> unlikely to add new modular controllers, the added complexity is
>> simply not justifiable.
>>
>> As a first step to drop cgroup module support, this patch changes the
>> two config options to bool from tristate and drops module related code
>> from the two controllers.
>>
> 
> I sugguested Daniel to do this for net_cls, and the change has been in
> net-next.
> 
> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=fe1217c4f3f7d7cbf8efdd8dd5fdc7204a1d65a8
> 
> I was planning to remove module support after that change goes into
> upstream. :)

I am fine with that, thanks Li.

>> Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
>> Cc: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
>> Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>> ---
>>   net/Kconfig               |  2 +-
>>   net/core/netprio_cgroup.c | 32 ++------------------------------
>>   net/sched/Kconfig         |  2 +-
>>   net/sched/cls_cgroup.c    | 23 ++---------------------
>>   4 files changed, 6 insertions(+), 53 deletions(-)
>>
> 
> The modular version of task_netprioidx() in include/net/netprio_cgroup.h
> can be removed.
> 
