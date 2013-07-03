From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: [PATCH next-20130703] net: sock: Add ifdef CONFIG_MEMCG_KMEM for mem_cgroup_sockets_{init,destroy}
Date: Wed, 3 Jul 2013 18:11:28 +0200
Message-ID: <CA+icZUWiXr=wFoXHA_V3jy0Bkg1Pc5b79LX5j1fnfgmOkYhKCg@mail.gmail.com>
References: <1372853998-15353-1-git-send-email-sedat.dilek@gmail.com>
	<51D41E34.5010802@huawei.com>
	<20130703152058.GA30267@dhcp22.suse.cz>
	<CA+icZUX+mB2v9ghdhaLvpncCu+yxP4xJzzbFxXisFsB2tDM7TA@mail.gmail.com>
	<20130703155958.GC5153@dhcp22.suse.cz>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Li Zefan <lizefan@huawei.com>, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org,
	sfr@canb.auug.org.au, linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130703155958.GC5153@dhcp22.suse.cz>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 3, 2013 at 5:59 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Wed 03-07-13 17:53:21, Sedat Dilek wrote:
>> On Wed, Jul 3, 2013 at 5:20 PM, Michal Hocko <mhocko@suse.cz> wrote:
>> > On Wed 03-07-13 20:51:00, Li Zefan wrote:
>> > [...]
>> >> [PATCH] memcg: fix build error if CONFIG_MEMCG_KMEM=n
>> >>
>> >> Fix this build error:
>> >>
>> >> mm/built-in.o: In function `mem_cgroup_css_free':
>> >> memcontrol.c:(.text+0x5caa6): undefined reference to
>> >> 'mem_cgroup_sockets_destroy'
>> >>
>> >> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> >> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
>> >> Signed-off-by: Li Zefan <lizefan@huawei.com>
>> >
>> > I am seeing the same thing I just didn't get to reporting it.
>> > The other approach is not bad as well but I find this tiny better
>> > because mem_cgroup_css_free should care only about a single cleanup
>> > function for whole kmem. If that one needs to do tcp kmem specific
>> > cleanup then it should be done inside kmem_cgroup_css_offline.
>> >
>>
>> As said in my other mail, for me this makes sense as it is a followup.
>>
>> But, still I don't know why sock.c has is own mem_cgroup_sockets_{init,destroy}.
>
> That is the only definition AFAICS (except for !CONFIG_NET where it
> expands to NOOP). Please note that memcg_init_kmem is a common kmem
> initializator and it needs to be prepared for !CONFIG_NET.
>
> The same applies to _destroy.
> Makes more sense now?
>

So, that stuff comes originally from the net-tree.

I understand the !CONFIG_NET case, but lack the understanding why
memcontrol.c needs _destroy.
Can you explain that (sorry /me is no mm-geek)?

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/net/core/sock.c?id=next-20130703#n147
[2] http://git.kernel.org/cgit/linux/kernel/git/next/linux-next.git/tree/include/net/sock.h?id=next-20130703#n73

> [...]
> --
> Michal Hocko
> SUSE Labs
